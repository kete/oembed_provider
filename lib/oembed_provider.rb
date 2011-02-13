require 'addressable/uri'
require 'oembed_providable'
# set OembedProvider.provide_name, etc. in your config/initializers or somewhere
class OembedProvider
  class << self
    def provider_url
      @@provider_url ||= String.new
    end

    def provider_url=(url)
      @@provider_url = url
    end

    def provider_name
      @@provider_name ||= String.new
    end

    def provider_name=(name)
      @@provider_name = name
    end

    def cache_age
      @@cache_age ||= nil
    end

    def cache_age=(age)
      @@cache_age = age
    end

    def version
      "1.0"
    end

    # every request has these, mostly required
    # mostly site wide
    # version is special case
    def base_attributes
      [:provider_url,
       :provider_name,
       :cache_age,
       :version]
    end

    # optional attributes
    # that are specific to an instance of the providable model
    def optional_attributes
      [:title,
       :author_name,
       :author_url,
       :thumbnail_url,
       :thumbnail_width,
       :thumbnail_height]
    end

    # these may be required depending on type
    # see 2.3.4.1 - 2.3.4.4 of spec
    # type specific attributes
    # all attributes listed for these types are required
    # the empty link array shows that nothing is required
    def required_attributes
      { :photo => [:url, :width, :height], 
        :video => [:html, :width, :height],
        :link => [],
        :rich => [:html, :width, :height] }
    end

    def controller_model_maps
      @@controller_model_maps ||= Hash.new
    end

    def controller_model_maps=(hash_map)
      @@controller_model_maps = hash_map
    end

    def find_provided_from(url)
      url = Addressable::URI.parse(url)
      submitted_url_params = ActionController::Routing::Routes.recognize_path(url.path, :method=>:get)
    
      controller = submitted_url_params[:controller]
      id = submitted_url_params[:id]

      # handle special cases where controllers are directly configured to point at a specific model
      model = OembedProvider.controller_model_maps[controller]

      # otherwise we use convention over configuration to determine model
      model = controller.singularize.camelize unless model
    
      model.constantize.find(id)
    end
  end
end
