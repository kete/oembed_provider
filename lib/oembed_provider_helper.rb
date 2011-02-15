# include this in your relevant helpers
# to add discoverability link, etc.
module OembedProviderHelper
  # hardcodes http as protocol
  # http is specified in http://oembed.com/
  def oembed_provider_links
    host_url = request.host
    escaped_request_url = request.url.sub('://', '%3A//')
    html = tag(:link, :rel => "alternate",
               :type => "application/json+oembed",
               :href => "http://#{host_url}/oembed?url=#{escaped_request_url}",
               :title => "JSON oEmbed for #{@title}")
    html += tag(:link, :rel => "alternate",
               :type => "application/xml+oembed",
               :href => "http://#{host_url}/oembed.xml?url=#{escaped_request_url}",
               :title => "XML oEmbed for #{@title}")
  end
end
