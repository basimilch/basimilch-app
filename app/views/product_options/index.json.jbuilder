json.array!(@product_options) do |product_option|
  json.extract! product_option, :id,
                                :name,
                                :description,
                                # :picture,
                                :size,
                                :size_unit,
                                :equivalent_in_milk_liters,
                                :canceled_at,
                                :canceled_reason,
                                :canceled_by_id,
                                :notes
  json.url product_option_url(product_option, format: :json)
end
