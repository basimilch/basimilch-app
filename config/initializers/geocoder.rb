Geocoder.configure(

  # SOURCE: https://github.com/alexreisner/geocoder/tree/v1.2.9
  #                                      #geocoding-service-lookup-configuration

  # Geocoding service timeout (secs)
  timeout:    2,

  # Geocoding service:
  # SOURCE: https://github.com/alexreisner/geocoder/tree/v1.2.9
  #                                                #google-google-google_premier
  # DOC: http://code.google.com/apis/maps/documentation/geocoding/#JSON
  # Terms of Service: http://code.google.com/apis/maps/terms.html#section_10_12
  lookup:     :google,     # Geocoder's default

  # IP address geocoding service:
  ip_lookup:  :freegeoip,     # Geocoder's default

  # ISO-639 language code
  language:   :de,

  # use HTTPS for lookup requests
  # use_https:  true,
  # FIXME: http://railsapps.github.io/openssl-certificate-verify-failed.html

  # set default units to kilometers
  units:      :km
)
