require 'oembed_provider'
require 'builder'

module OembedProvidable #:nodoc:
  def self.included(base)
    base.send(:include, OembedProvidable::Provided)
  end  

  # use this to make your model able to respond to requests
  # against the OembedProviderController
  module Provided
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def oembed_providable_as(*args)
        # don't allow multiple calls
        return if self.included_modules.include?(OembedProvidable::Provided::InstanceMethods)

        send :include, OembedProvidable::Provided::InstanceMethods

        specs = args.last.is_a?(Hash) ? args.pop : Hash.new
        
        oembed_type = args.first

        if !oembed_type.is_a?(Symbol) || ![:photo, :video, :link, :rich].include?(oembed_type)
            raise ArgumentError, "oEmbed type must be :photo, :video, :link, or :rich"
        end

        # create the scoped oembed_response model
        const_set("OembedResponse", Class.new).class_eval do
          cattr_accessor :providable_class
          self.providable_class = self.name.split('::').first.constantize

          cattr_accessor :providable_specs
          self.providable_specs = specs

          cattr_accessor :oembed_version
          self.oembed_version = OembedProvider.version

          cattr_accessor :providable_oembed_type
          self.providable_oembed_type = oembed_type

          the_provider_name = specs[:provider_name].present? ? specs[:provider_name] : OembedProvider.provider_name
          raise ArgumentError, "Missing provider_name setting in either OembedProvider.provider_name or oembed_providable_as spec." unless the_provider_name.present?
          cattr_accessor :providable_provider_name
          self.providable_provider_name = the_provider_name

          the_provider_url = specs[:provider_url].present? ? specs[:provider_url] : OembedProvider.provider_url
          raise ArgumentError, "Missing provider_url setting in either OembedProvider.provider_url or oembed_providable_as spec." unless the_provider_url.present?
          cattr_accessor :providable_provider_url
          self.providable_provider_url = the_provider_url

          # cache_age is optional and can be nil
          the_cache_age = specs[:cache_age].present? ? specs[:cache_age] : OembedProvider.cache_age
          cattr_accessor :providable_cache_age
          self.providable_cache_age = the_cache_age

          # these are what the response should return
          # as per the oEmbed Spec
          # http://oembed.com/#section2 - 2.3.4
          # :type is required, but is model wide and set via oembed_providable_as
          # :version is required and is handled below
          attributes_to_define = OembedProvider.optional_attributes

          attributes_to_define += OembedProvider.required_attributes[oembed_type]

          # site wide values
          # :provider_name, :provider_url, :cache_age
          # can be set via oembed_providable_as
          # or set via OembedProvider initialization
          attributes_to_define += OembedProvider.base_attributes

          # not relevant to links, but everything else
          attributes_to_define += [:maxheight, :maxwidth] unless oembed_type == :link

          cattr_accessor :providable_all_attributes
          self.providable_all_attributes = attributes_to_define

          attributes_to_define.each do |attr|
            attr_accessor attr
          end

          # datastructure is hash
          # with attribute name as key
          # and method to call on providable as value
          # both as symbol
          # oembed_providable_as can specify method to call for an attribute
          def self.method_specs_for(attributes)
            method_specs = Hash.new
            attributes.each do |attr|
              if providable_specs.keys.include?(attr)
                method_specs[attr] = providable_specs[attr]
              else
                method_specs[attr] = attr
              end
            end
            method_specs
          end

          cattr_accessor :optional_attributes_specs
          self.optional_attributes_specs = method_specs_for(OembedProvider.optional_attributes)

          cattr_accessor :required_attributes_specs
          self.required_attributes_specs = method_specs_for(OembedProvider.required_attributes[oembed_type])

          # options are added to handle passing maxwidth and maxheight
          # relevant to oembed types photo, video, and rich
          # if they have a thumbnail, then these also much not be bigger
          # than maxwidth, maxheight
          def initialize(providable, options = {})
            self.version = self.class.oembed_version

            # we set maxwidth, maxheight first
            # so subsequent calls to providable.send(some_method_name)
            # can use them to adjust their values
            unless type == :link
              self.maxheight = options[:maxheight].to_i if options[:maxheight].present?
              self.maxwidth = options[:maxwidth].to_i if options[:maxwidth].present?

              providable.oembed_max_dimensions = { :height => maxheight, :width => maxwidth }
            end

            self.class.required_attributes_specs.each do |k,v|
              value = providable.send(v)
              raise ArgumentError, "#{k} is required for an oEmbed response." if value.blank?

              send(k.to_s + '=', value)
            end

            self.class.optional_attributes_specs.each do |k,v|
              send(k.to_s + '=', providable.send(v))
            end

            self.provider_name = self.class.providable_provider_name
            self.provider_url =  self.class.providable_provider_url
            self.cache_age = self.class.providable_cache_age
          end

          def type
            self.class.providable_oembed_type
          end

          # because this isn't an AR record, doesn't include to_xml
          # plus we need a custom
          # root node needs to replaced with oembed rather than oembed_response
          def to_xml
            attributes = self.class.providable_all_attributes

            builder = Nokogiri::XML::Builder.new do |xml|
              xml.oembed {
                attributes.each do |attr|
                  next if attr.to_s.include?('max')
                  value = self.send(attr)
                  xml.send(attr, value) if value.present?
                end
              }
            end

            builder.to_xml
          end

          # override default to_json
          def as_json(options = {})
            as_json = super(options)

            attributes = self.class.providable_all_attributes

            as_json.delete_if { |k,v| v.blank? }

            as_json.delete_if { |k,v| k.include?('max') }

            as_json
          end


        end
      end

      def oembed_type
        self::OembedResponse.providable_oembed_type
      end
    end

    module InstanceMethods
      def oembed_response(options = {})
        @oembed_response ||= self.class::OembedResponse.new(self, options)
      end

      def oembed_max_dimensions=(options)
        options = { :height => nil, :width => nil } if options.blank?
        @oembed_max_dimensions = options
      end

      def oembed_max_dimensions
        @oembed_max_dimensions || { :height => nil, :width => nil }
      end
    end
  end
end
