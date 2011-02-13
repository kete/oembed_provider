# -*- coding: utf-8 -*-
require 'test_helper'

class OembedProviderControllerTest < ActionController::TestCase
  context "The oembed provider controller" do
    setup do
      @photo = Factory.create(:photo)
    end

    should "endpoint" do
      get :endpoint, :url => "http://example.com/photos/#{@photo.id}"
      assert_response :success
    end

    should "endpoint with format json" do
      @request.accept = "text/javascript"
      get :endpoint, :url => "http://example.com/photos/#{@photo.id}", :format => 'json'
      assert_response :success
    end

    should "endpoint with format json and callback, return json-p" do
      @request.accept = "text/javascript"
      get :endpoint, :url => "http://example.com/photos/#{@photo.id}", :format => 'json', :callback => 'myCallback'
      assert_response :success
    end

    should "endpoint with format xml" do
      @request.accept = "text/xml"
      get :endpoint, :url => "http://example.com/photos/#{@photo.id}", :format => 'xml'
      assert_response :success
    end
  end
end

