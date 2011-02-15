# -*- coding: utf-8 -*-
require 'test_helper'

class OembedProvidableTest < ActiveSupport::TestCase
  n = 0

  context "A model class that includes OembedProvidable" do

    context "when declaring oembed_providable_as" do 
      setup do
        n += 1
        @a_class_name = "Klass#{n}"

        Object.const_set(@a_class_name, Class.new(ActiveRecord::Base)).class_eval do
          include OembedProvidable
        end

        @a_class = @a_class_name.constantize
      end

      should "not be able to be able to declare oembed_providable_as without an argument for type" do
        assert_raise(ArgumentError) { @a_class.send(:oembed_providable_as) }
      end

      should "be able to be able to declare oembed_providable_as with a type" do
        assert_nothing_raised { @a_class.send(:oembed_providable_as, :link) }
      end

      should "be able to be able to declare oembed_providable_as with a type and a hash for a spec" do
        assert_nothing_raised { @a_class.send(:oembed_providable_as, :link, { :title => :label }) }
      end

      should "have the ability to return an oembed_type" do
        @a_class.send(:oembed_providable_as, :link)
        assert @a_class.respond_to?(:oembed_type)
        assert_equal @a_class.oembed_type, :link
      end
    end

    context "will have method" do 
      setup do
        @method_specs = Hash.new        
      end

      context "methods_specs_for that" do 
        should "return an array of hashes that match defaults when there is no hash of overriding specs" do
          assert_nothing_raised { Photo::OembedResponse.send(:method_specs_for, OembedProvider.optional_attributes) }
          OembedProvider.optional_attributes.each { |attr| @method_specs[attr] = attr }
          results_for_test = Photo::OembedResponse.send(:method_specs_for, OembedProvider.optional_attributes)
          assert_equal results_for_test, @method_specs
        end

        should "return an array of hashes that take into account overriding specs" do
          OembedProvider.optional_attributes.each { |attr| @method_specs[attr] = attr }
          @method_specs[:title] = :label
          results_for_test = Item::OembedResponse.send(:method_specs_for, OembedProvider.optional_attributes)
          assert_equal results_for_test, @method_specs
        end
      end

      context "optional_attributes_specs set and " do 
        should "match the OembedProvider defaults when there is no hash of overriding specs in the oembed_providable_as call" do
          assert Photo::OembedResponse.respond_to?(:optional_attributes_specs)
          OembedProvider.optional_attributes.each { |attr| @method_specs[attr] = attr }
          assert_equal Photo::OembedResponse.optional_attributes_specs, @method_specs
        end

        should "match the oembed_providable_as specs if they are specified" do
          OembedProvider.optional_attributes.each { |attr| @method_specs[attr] = attr }
          @method_specs[:title] = :label
          assert_equal Item::OembedResponse.optional_attributes_specs, @method_specs
        end
      end

      context "required_attributes_specs set and " do
        should "match the OembedProvider defaults when there is no hash of overriding specs in the oembed_providable_as call" do
          assert Photo::OembedResponse.respond_to?(:required_attributes_specs)
          OembedProvider.required_attributes[:photo].each { |attr| @method_specs[attr] = attr }
          assert_equal Photo::OembedResponse.required_attributes_specs, @method_specs
        end

        should "match the oembed_providable_as specs if they are specified" do
          Object.const_set("RichItem", Class.new(ActiveRecord::Base)).class_eval do
            include OembedProvidable
            oembed_providable_as :rich, :html => :description
            def description
              "<h1>some html</h1>"
            end
          end

          OembedProvider.required_attributes[:rich].each { |attr| @method_specs[attr] = attr }
          @method_specs[:html] = :description
          assert_equal RichItem::OembedResponse.required_attributes_specs, @method_specs
        end
      end
      context "providable_all_attributes set and " do
        should "have all relevant attributes for the type" do
          assert Item::OembedResponse.respond_to?(:providable_all_attributes)
          all_attributes = OembedProvider.optional_attributes +
            OembedProvider.required_attributes[:link] +
            OembedProvider.base_attributes
          assert_equal all_attributes, Item::OembedResponse.providable_all_attributes
        end
      end
    end
  end

  context "A photo that includes OembedProvidable" do
    setup do
      @photo = Factory.create(:photo)
    end

    should "have an oembed_response object" do
      assert @photo.oembed_response
    end

    should "have an oembed_max_dimensions object when maxheight and maxwidth are specified" do
      maxheight = 400
      maxwidth = 600
      assert @photo.oembed_response(:maxheight => maxheight,
                                    :maxwidth => maxwidth)
      assert_equal maxheight, @photo.oembed_response.maxheight
      assert_equal maxwidth, @photo.oembed_response.maxwidth

      assert @photo.respond_to?(:oembed_max_dimensions)
      assert_equal maxheight, @photo.oembed_max_dimensions[:height]
      assert_equal maxwidth, @photo.oembed_max_dimensions[:width]
    end

    context "has an oembed_response and" do
      setup do
        @response = @photo.oembed_response
      end

      context "has required attribute that" do 
        should "be title" do
          assert @response.title.present?
        end

        should "be version" do
          assert @response.version.present?
        end

        should "be height" do
          assert @response.height.present?
        end

        should "be width" do
          assert @response.width.present?
        end

        should "be url" do
          assert @response.url.present?
        end

        should "be provider_url" do
          assert @response.provider_url.present?
        end

        should "be provider_name" do
          assert @response.provider_name.present?
        end
      end
      
      context "has can have optional attribute that" do
        should "be author_name" do
          @photo = Factory.create(:photo, :author_name => "Snappy")
          assert @photo.oembed_response.author_name.present?
          assert_equal "Snappy", @photo.oembed_response.author_name
        end

        should "be author_url" do
          @photo = Factory.create(:photo, :author_url => "http://snapsnap.com")
          assert @photo.oembed_response.author_url.present?
          assert_equal "http://snapsnap.com", @photo.oembed_response.author_url
        end

        should "be thumbnail_url" do
          @photo = Factory.create(:photo, :thumbnail_url => "http://snapsnap.com/thumb.jpg")
          assert @photo.oembed_response.thumbnail_url.present?
          assert_equal "http://snapsnap.com/thumb.jpg", @photo.oembed_response.thumbnail_url
        end

        should "be thumbnail_width" do
          @photo = Factory.create(:photo, :thumbnail_width => 50)
          assert @photo.oembed_response.thumbnail_width.present?
          assert_equal 50, @photo.oembed_response.thumbnail_width
        end

        should "be thumbnail_height" do
          @photo = Factory.create(:photo, :thumbnail_height => 50)
          assert @photo.oembed_response.thumbnail_height.present?
          assert_equal 50, @photo.oembed_response.thumbnail_height
        end
      end

      context "when returning json" do
        should "succeed" do
          assert @response.as_json
          assert !@response.to_json.to_s.include?(':null')
        end
      end

      context "when returning xml" do
        should "succeed" do
          assert @response.to_xml
        end
      end
    end
  end
end
