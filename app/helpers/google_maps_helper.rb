# SOURCE: http://www.rails-dev.com/custom-view-helpers-in-rails-4
module GoogleMapsHelper

  GOOGLE_MAPS_EMBED_API_BROWSER_KEY = ENV['GOOGLE_MAPS_EMBED_API_BROWSER_KEY']

  class Type < Enum
    enum :TERRAIN
    enum :ROADMAP
    enum :HYBRID
    enum :SATELLITE
  end

  def embedded_map(geocoded_item, options = {})
    content_tag :div, class: 'embedded-map-container' do
      content_tag :iframe,
                  nil,
                  class: 'embedded-map',
                  disabled: true,
                  width:  options[:width]   || '100%',
                  height: options[:height]  || '500px',
                  frameborder: '0',
                  style: 'border:0',
                  allowfullscreen: true,
                  src: embedded_map_url(geocoded_item, options)
    end
  end

  # DOC: https://developers.google.com/maps/documentation/embed/guide
  def embedded_map_url(geocoded_item,
                       width: '100%',
                       height: '300px',
                       zoom: 15,
                       origin_geocoded_item: nil,
                       maptype: Type::ROADMAP)
    geocoded_item.try :geocoded? or raise "#{geocoded_item} is not geocoded"
    unless maptype.is_a? Type
      raise "#{maptype.inspect} is not a GoogleMapsHelper::Type"
    end
    url = "https://www.google.com/maps/embed/v1"
    if origin_geocoded_item.present?
      url << "/directions?"
      url << "origin=#{origin_geocoded_item.full_postal_address separator: '+'}"
      url << "&destination=#{geocoded_item.full_postal_address separator: '+'}"
      url << "&mode=walking"
    else
      url << "/place?"
      url << "q=#{geocoded_item.latitude},#{geocoded_item.longitude}"
      url << "&zoom=#{zoom}"
      url << "&attribution_source=Genossenschaft+basimilch"
    end
    url << "&maptype=#{maptype}"
    url << "&key=#{GOOGLE_MAPS_EMBED_API_BROWSER_KEY}"
    url << "&language=#{I18n.locale}"
  end

  def map_image_tag(geocoded_items, options = {})
    html_options = {class: 'static-map'}
    html_options[:width]  = options[:width]  if options[:width].present?
    html_options[:height] = options[:height] if options[:height].present?
    image_tag map_static_url(geocoded_items, options), html_options
  end

  def map_fit_image_tag(geocoded_items, options = {})
    html_options = {css_class: 'static-map'}
    html_options[:height] = options.pop(:height)
    html_options[:width]  = options.pop(:width)
    fit_image_tag map_static_url(geocoded_items, options), html_options
  end

  # The following list shows the approximate level of detail you can
  # expect to see at each zoom level:
  #   1: World
  #   5: Landmass/continent
  #   10: City
  #   15: Streets
  #   20: Buildings
  # The max image size is 640x640 (which returns 1280x1280 pixels if scale=2)
  # DOC: https://developers.google.com/maps/documentation/static-maps/
  def map_static_url(geocoded_items,
                     width: 640,
                     height: 640,
                     zoom: 15,
                     maptype: Type::ROADMAP)
    is_collection =  geocoded_items.respond_to? :each
    unless maptype.is_a? Type
      raise "#{maptype.inspect} is not a GoogleMapsHelper::Type"
    end
    url = "http://maps.google.com/maps/api/staticmap?"
    url << "size=#{width}x#{height}&sensor=false"
    url << "&zoom=#{zoom}" unless is_collection
    url << "&scale=2"
    if [Type::HYBRID, Type::SATELLITE].include? maptype
      url << "&format=jpg"
    else
      url << "&format=png"
    end
    url << "&maptype=#{maptype}"
    url << "&markers=color:blue"
    geocoded_items = [geocoded_items] unless is_collection
    geocoded_items.each do |geocoded_item|
      geocoded_item.try :geocoded? or raise "#{geocoded_item} is not geocoded"
      url << "|#{geocoded_item.latitude}%2C#{geocoded_item.longitude}"
    end
    url
  end

end
