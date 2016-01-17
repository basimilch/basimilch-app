json.array!(@job_signups) do |job_signup|
  json.extract! job_signup, :id, :user_id, :job_id
  json.url job_signup_url(job_signup, format: :json)
end
