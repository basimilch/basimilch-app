json.array!(@share_certificates) do |share_certificate|
  json.extract! share_certificate, :id, :user_id, :sent_at, :payed_at, :returned_at, :notes
  json.url share_certificate_url(share_certificate, format: :json)
end
