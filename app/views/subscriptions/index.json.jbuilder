json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :id, :name, :basic_units, :supplement_units, :depot_id, :notes
  json.url subscription_url(subscription, format: :json)
end
