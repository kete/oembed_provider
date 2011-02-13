# -*- coding: utf-8 -*-
require 'test_helper'

Webrat.configure do |config|
  config.mode = :rails
end

class OembedTest < ActionController::IntegrationTest
  context "A providable object when its url is request from the oembed endpoint" do
    include Webrat::HaveTagMatcher
    setup do
      @photo = Factory.create(:photo)
    end
    
    should "return correct json for the providable object" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      visit "/oembed?url=#{escaped_url}"
      photo_from_response = ActiveSupport::JSON.decode response.body
      assert_equal ActiveSupport::JSON.decode(@photo.oembed_response.to_json), photo_from_response
    end

    should "return correct json for the providable object when .json" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      visit "/oembed.json?url=#{escaped_url}"
      photo_from_response = ActiveSupport::JSON.decode response.body
      assert_equal ActiveSupport::JSON.decode(@photo.oembed_response.to_json), photo_from_response
    end

    should "return correct json for the providable object when query string specifies format=json" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      visit "/oembed?url=#{escaped_url}&format=json"
      photo_from_response = ActiveSupport::JSON.decode response.body
      assert_equal ActiveSupport::JSON.decode(@photo.oembed_response.to_json), photo_from_response
    end

    should "return correct json-p for the providable object when .json and callback specified" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      callback_name = 'myCallback'
      visit "/oembed.json?url=#{escaped_url}&callback=#{callback_name}"
      assert response_body.include?(callback_name)
      photo_from_response = ActiveSupport::JSON.decode response.body.sub("#{callback_name}(", '').chomp(');')
      assert_equal ActiveSupport::JSON.decode(@photo.oembed_response.to_json), photo_from_response
    end

    should "return correct json-p for the providable object when .json and variable specified" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      variable_name = 'myVar'
      visit "/oembed.json?url=#{escaped_url}&variable=#{variable_name}"
      assert response_body.include?(variable_name)
      photo_from_response = ActiveSupport::JSON.decode response.body.sub("var #{variable_name} = ", '').chomp(';')
      assert_equal ActiveSupport::JSON.decode(@photo.oembed_response.to_json), photo_from_response
    end

    should "return correct json-p for the providable object when .json and variable and callback specified" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      variable_name = 'myVar'
      callback_name = 'myCallback'
      visit "/oembed.json?url=#{escaped_url}&variable=#{variable_name}&callback=#{callback_name}"
      assert response_body.include?(variable_name)
      assert response_body.include?(callback_name)
      stripped_to_json = response.body.sub("var #{variable_name} = ", '').sub("\n#{callback_name}(#{variable_name})", '').chomp(';').chomp(';')
      photo_from_response = ActiveSupport::JSON.decode stripped_to_json
      assert_equal ActiveSupport::JSON.decode(@photo.oembed_response.to_json), photo_from_response
    end

    should "return correct xml for the providable object when .xml" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      visit "/oembed.xml?url=#{escaped_url}"
      assert_equal @photo.oembed_response.to_xml, response.body
    end

    should "return correct xml for the providable object when query string specifies format=xml" do
      escaped_url = "http%3A//example.com/photos/#{@photo.id}"
      visit "/oembed?url=#{escaped_url}&format=xml"
      assert_equal @photo.oembed_response.to_xml, response.body
    end
    
    # TODO: maxheight and maxwidth parameter passing results in correct version of image, etc.
  end
end
