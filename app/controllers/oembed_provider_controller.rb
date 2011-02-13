class OembedProviderController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  # GET /oembed?url=... json by default
  # GET /oembed.json?url=...
  # GET /oembed.json?url=...&callback=myCallback
  # GET /oembed.xml?url=...
  def endpoint
    # get object that we want an oembed_response from
    # based on url
    # and get its oembed_response
    media_item = OembedProvider.find_provided_from(params[:url])
    options = Hash.new
    max_dimensions = [:maxwidth, :maxheight]

    unless media_item.class::OembedResponse.providable_oembed_type == :link
      max_dimensions.each { |dimension| options[dimension] = params[dimension] if params[dimension].present? }
    end

    @oembed_response = media_item.oembed_response(options)

    # to_xml and to_json overidden in oembed_providable module
    # to be properly formatted
    # TODO: handle unauthorized case
    respond_to do |format|
      if @oembed_response
        format.html { render_json @oembed_response.to_json } # return json for default
        format.json { render_json @oembed_response.to_json }
        format.xml  { render :xml => @oembed_response }
      else
        format.all { render_404 }
      end
    end
  end

  protected
  # thanks to http://blogs.sitepoint.com/2006/10/05/json-p-output-with-rails/
  def render_json(json, options={})
    callback, variable = params[:callback], params[:variable]
    response = begin
                 if callback && variable
                   "var #{variable} = #{json};\n#{callback}(#{variable});"
                 elsif variable
                   "var #{variable} = #{json};"
                 elsif callback
                   "#{callback}(#{json});"
                 else
                   json
                 end
               end
    render({:content_type => :js, :text => response}.merge(options))
  end
end
