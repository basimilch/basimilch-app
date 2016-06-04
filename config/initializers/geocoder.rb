Geocoder.configure(

  # SOURCE: https://github.com/alexreisner/geocoder/tree/v1.3.6#geocoding-service-lookup-configuration

  # Geocoding service timeout (secs)
  timeout:    15,

  # Geocoding service:
  # SOURCE: https://github.com/alexreisner/geocoder/tree/v1.3.6#google-google
  # DOC: http://code.google.com/apis/maps/documentation/geocoding/#JSON
  # Terms of Service: http://code.google.com/apis/maps/terms.html#section_10_12
  lookup:     :google,     # Geocoder's default

  google: {
    api_key: ENV['GOOGLE_MAPS_GEOCODING_API_KEY'],
    use_https:  Rails.env.production? # use HTTPS for lookup requests
    # FIXME: http://railsapps.github.io/openssl-certificate-verify-failed.html
  },

  # IP address geocoding service:

  # DOC: https://github.com/alexreisner/geocoder/tree/v1.3.6#ipinfoio-ipinfo_io
  # DOC: http://ipinfo.io/pricing
  ip_lookup:  :ipinfo_io,   # up to 1,000 daily requests in the free plan

  ipinfo_io: {
    use_https: false # the free plan does not support SSL/HTTPS
  },

  # ISO-639 language code
  language:   :de,

  # set default units to kilometers
  units:      :km
)
