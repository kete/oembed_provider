class Item < ActiveRecord::Base
  include OembedProvidable
  oembed_providable_as :link, :title => :label
end
