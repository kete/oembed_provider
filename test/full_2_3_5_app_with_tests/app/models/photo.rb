class Photo < ActiveRecord::Base
  include OembedProvidable
  oembed_providable_as :photo
  def version
    1
  end
end
