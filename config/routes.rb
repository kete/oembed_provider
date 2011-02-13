# extend routes for oembed provider endpoint
ActionController::Routing::Routes.draw do |map|
  # only one route needed
  map.with_options :controller => 'oembed_provider' do |oembed_provider|
    oembed_provider.connect 'oembed.:format', :action => 'endpoint'
    oembed_provider.connect 'oembed', :action => 'endpoint'
  end
end
