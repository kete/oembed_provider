class Photo < ActiveRecord::Base
  include OembedProvidable
  oembed_providable_as :photo
end
