json.array!(@depots) do |depot|
  json.extract! depot, :id,
                       :name,
                       :postal_address,
                       :postal_address_supplement,
                       :postal_code,
                       :city,
                       :country,
                       :exact_map_coordinates,
                       # :picture,
                       :directions,
                       :opening_hours,
                       :notes
  json.url depot_url(depot, format: :json)
end
