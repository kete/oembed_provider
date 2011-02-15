# -*- coding: utf-8 -*-
require 'test_helper'

Webrat.configure do |config|
  config.mode = :rails
end

class OembedTest < ActionController::IntegrationTest
  context "A providable object when its url is request from the oembed endpoint" do
    setup do
      @photo = Factory.create(:photo)
      @url_without_protocol = "example.com/photos/#{@photo.id}"
      @escaped_url = "http%3A//#{@url_without_protocol}"
      @normal_url = "http://#{@url_without_protocol}"
    end
    
    should "return correct json for the providable object" do
      visit "/oembed?url=#{@escaped_url}"
      assert_json_equal_to(response.body)
    end

    should "return correct json for the providable object when .json" do
      visit "/oembed.json?url=#{@escaped_url}"
      assert_json_equal_to(response.body)
    end

    should "return correct json for the providable object when query string specifies format=json" do
      visit "/oembed?url=#{@escaped_url}&format=json"
      assert_json_equal_to(response.body)
    end

    should "return correct json-p for the providable object when .json and callback specified" do
      callback_name = 'myCallback'
      visit "/oembed.json?url=#{@escaped_url}&callback=#{callback_name}"
      assert response.body.include?(callback_name)
      assert_json_equal_to(response.body.sub("#{callback_name}(", '').chomp(');'))
    end

    should "return correct json-p for the providable object when .json and variable specified" do
      variable_name = 'myVar'
      visit "/oembed.json?url=#{@escaped_url}&variable=#{variable_name}"
      assert response.body.include?(variable_name)
      assert_json_equal_to(response.body.sub("var #{variable_name} = ", '').chomp(';'))
    end

    should "return correct json-p for the providable object when .json and variable and callback specified" do
      variable_name = 'myVar'
      callback_name = 'myCallback'
      visit "/oembed.json?url=#{@escaped_url}&variable=#{variable_name}&callback=#{callback_name}"
      assert response.body.include?(variable_name)
      assert response.body.include?(callback_name)
      stripped_to_json = response.body.sub("var #{variable_name} = ", '').sub("\n#{callback_name}(#{variable_name})", '').chomp(';').chomp(';')
      assert_json_equal_to(stripped_to_json)
    end

    should "return correct xml for the providable object when .xml" do
      visit "/oembed.xml?url=#{@escaped_url}"
      assert_equal @photo.oembed_response.to_xml, response.body
    end

    should "return correct xml for the providable object when query string specifies format=xml" do
      visit "/oembed?url=#{@escaped_url}&format=xml"
      assert_equal @photo.oembed_response.to_xml, response.body
    end
    
    # test helper here as integration test rather than unit/helpers
    # only one helper and easier to do and effective in practice
    context "when visiting providable url, the page" do
      should "oembed links in the header" do
        visit @normal_url
        assert response.body.include?("application/json+oembed")
        assert response.body.include?("/oembed?url=#{@escaped_url}")
        assert response.body.include?("application/xml+oembed")
        assert response.body.include?("/oembed.xml?url=#{@escaped_url}")
      end
    end

    # WARNING: maxheight and maxwidth parameter passing
    # results in correct version of image, etc.
    # is left to application specific testing by application using the engine
    # in other words, implement it in YOUR tests
  end
  private
  
  def assert_json_equal_to(response_body)
    assert_equal ActiveSupport::JSON.decode(@photo.oembed_response.to_json), ActiveSupport::JSON.decode(response_body)
  end
end
