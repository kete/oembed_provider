# -*- coding: utf-8 -*-
require 'test_helper'

class OembedProviderTest < ActiveSupport::TestCase
  context "The OembedProvider object" do
    should "be able to set and return its provider name" do
      name = "Media Conglomerate International"
      OembedProvider.provider_name = name
      assert_equal OembedProvider.provider_name, name
    end

    should "be able to set and return its provider url" do
      url = "http://example.com"
      OembedProvider.provider_url = url
      assert_equal OembedProvider.provider_url, url
    end

    should "be able to set and return its cache age" do
      age = "1440"
      OembedProvider.cache_age = age
      assert_equal OembedProvider.cache_age, age
    end

    should "return version as 1.0 of oEmbed spec" do
      assert_equal "1.0", OembedProvider.version
    end

    should "have an array of base attribute keys" do
      base_attributes = [:provider_url,
                         :provider_name,
                         :cache_age,
                         :version]

      assert_equal OembedProvider.base_attributes, base_attributes
    end

    should "have an array of optional attribute keys" do
      optional_attributes = [:title,
                             :author_name,
                             :author_url,
                             :thumbnail_url,
                             :thumbnail_width,
                             :thumbnail_height]

      assert_equal OembedProvider.optional_attributes, optional_attributes
    end

    should "have a hash of keyed by oembed type with required attribute keys" do
      required_attributes = {
        :photo => [:url, :width, :height], 
        :video => [:html, :width, :height],
        :link => [],
        :rich => [:html, :width, :height] }
      
      assert_equal OembedProvider.required_attributes, required_attributes
    end

    should "have a hash of keyed by oembed type photo with required attribute keys" do
      requires = [:url, :width, :height]
      assert_equal OembedProvider.required_attributes[:photo], requires
    end

    should "have a hash of keyed by oembed type video with required attribute keys" do
      requires = [:html, :width, :height]
      assert_equal OembedProvider.required_attributes[:video], requires
    end

    should "have a hash of keyed by oembed type link with required attribute keys" do
      requires = []
      assert_equal OembedProvider.required_attributes[:link], requires
    end

    should "have a hash of keyed by oembed type rich with required attribute keys" do
      requires = [:html, :width, :height]
      assert_equal OembedProvider.required_attributes[:rich], requires
    end

    context "have an cattr accessor for mapping controllers that aren't tableized version of models, to their corresponding models" do
      should "be able to set and read controller_model_maps" do
        assert OembedProvider.respond_to?(:controller_model_maps)
        assert_equal Hash.new, OembedProvider.controller_model_maps
        test_hash = { :images => 'StillImage' }
        OembedProvider.controller_model_maps = test_hash
        assert_equal test_hash, OembedProvider.controller_model_maps
        test_hash[:audio] = 'AudioRecording'
        OembedProvider.controller_model_maps[:audio] = 'AudioRecording'
        assert_equal test_hash, OembedProvider.controller_model_maps
      end
    end

    should "be able to answer find_provided_from with provided object based on passed in url" do
      @photo = Factory.create(:photo)
      url = "http://example.com/photos/#{@photo.id}"
      assert_equal @photo, OembedProvider.find_provided_from(url)
    end
  end
end
