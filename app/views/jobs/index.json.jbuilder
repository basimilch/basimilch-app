json.array!(@jobs) do |job|
  json.extract! job, :id, :title, :description, :date, :start_time, :end_time, :place, :address, :size, :user_id
  json.url job_url(job, format: :json)
end
