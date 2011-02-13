# -*- coding: utf-8 -*-
require 'test_helper'

# This file is not in integration/ because when run with
# 'rake', it causes segfaults in the test suite

# ATTN: Before runnings these tests, be sure to turn
# off all extensions and popup blockers in Safari

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  setup do |session|
    session.host! "localhost:3001"
  end
end

Webrat.configure do |config|
  config.mode = :selenium
  config.application_environment = :test
  config.selenium_browser_key = '*safari'
end

class SeleniumTest < ActionController::IntegrationTest
  context "Using Selenium to test javascript functionality" do

    # DEBUG: This works so if the others don't, try just this one
    # should "be able to visit the homepage" do
    #   visit "/"
    #   assert_contain "Welcome aboard"
    # end

    should "be able to translate an item via AJAX" do
      item = create_item
      click_link "Français"
      assert current_url =~ /\/en\/items\/#{item.id}$/
      assert_contain "Translate from English to Français"
      fill_in 'item_translation_label', :with => 'Certains Point'
      click_button 'Create'
      assert_contain 'Translation was successfully created.'
    end

    should "be able to switch translations" do
      item = create_item
      click_link "Français"
      assert current_url =~ /\/en\/items\/#{item.id}$/
      assert_contain "Translate from English to Français"
      click_link "Suomi"
      assert current_url =~ /\/en\/items\/#{item.id}$/
      assert_contain "Translate from English to Suomi"
    end

    should "be able to close the translations box" do
      item = create_item
      click_link "Français"
      click_link "[close]"
      assert_not_contain "Translate from English to Français"
    end

    should "be able to use the auto translate functionality" do
      item = create_item
      visit "/en/items/#{item.id}/translations/new?to_locale=fr"
      click_link '[auto translate]'
      sleep 1 # ugly way to wait for google to do it's thing
      click_button 'Create'
      assert_contain 'Translation was successfully created.'
      assert_contain 'Certains Point'
    end

  end

  private

  def create_item
    visit "/en/items"
    click_link "New item"
    fill_in 'item_label', :with => 'Some Item'
    fill_in 'item_value', :with => '$3.50'
    fill_in 'item_locale', :with => 'en'
    click_button 'Create'
    assert_contain 'Item was successfully created.'
    Item.last
  end
end
