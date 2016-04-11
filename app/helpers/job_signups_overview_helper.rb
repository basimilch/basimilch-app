module JobSignupsOverviewHelper

  def tr_class(job_signup, job)
    if job_signup.canceled?
      "canceled"
    elsif job.past?
      "success"
    elsif job.ongoing?
      ""
    else
      "warning"
    end
  end

  def status_icon(job_signup, job)
    if job_signup.canceled?
      icon :remove, t('.canceled')
    elsif job.past?
      icon :ok, t('.done')
    elsif job.ongoing?
      icon :bell, t("time.now")
    else
      icon :time do
        time_tag job.start_at do
          job.start_at.relative_in_words
        end
      end
    end
  end
end
