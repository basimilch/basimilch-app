class JobsController < ApplicationController

  JOBS_PER_PAGE = 30

  before_action :require_logged_in_user
  before_action :admin_user,  except: [:index, :show, :signup_current_user]
  before_action :set_job,     only:   [:show, :edit, :update, :destroy,
                                       :signup_current_user,
                                       :signup_users, :unregister_user]

  # GET /jobs
  # GET /jobs.json
  def index
    # TODO: Using .to_a "preloads" the query. Investigate if it's a good practice.
    # @jobs = Job.future.page(params[:page]).per_page(JOBS_PER_PAGE).to_a
    if month_filter = params[:month]
      @jobs = Job.in_this_years_month(month_filter)
    else
      @jobs = Job.future
    end
    @job_type_id = job_type_param
    @jobs = @jobs
               .job_type(@job_type_id)
               .page(page_query_param)
               .per_page(JOBS_PER_PAGE)
    if page_query_param > @jobs.total_pages
      redirect_to jobs_path(page: @jobs.total_pages,
                            job_type: params[:job_type],
                            month: params[:month])
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    if @job.past?
      flash_now_t :warning, :job_is_in_the_past
    elsif @job.user_signed_up? current_user
      flash_now_t :info, @job.full? ? :current_user_signed_up_and_job_full :
                                      :current_user_signed_up
    end
  end

  # GET /jobs/new
  def new
    if original_job = Job.find_by(id: params[:duplicate])
      @job_type = original_job.job_type
      @job = original_job.dup
    elsif @job_type = JobType.find_by(id: params[:job_type])
      @job = Job.new do |j|
        j.job_type    = @job_type
        j.title       = @job_type.title
        j.description = @job_type.description
        j.place       = @job_type.place
        j.address     = @job_type.address
        j.slots       = @job_type.slots
        j.user        = @job_type.user
        j.start_at    = Time.current + 1.hours
        j.end_at      = Time.current + 3.hours
      end
    else
      @job = Job.new
    end
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)
    respond_to do |format|
      if @job.save_series
        record_activity :create, @job
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
      else
        @job_type = JobType.find_by(id: @job.job_type_id)
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        record_activity :update, @job
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    record_activity :destroy, @job # Must come before the destroy action.
    @job.job_signups.each do |job_signup|
      UserMailer.job_cancelled_notification(job_signup.user, @job).deliver_later
    end
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def signup_current_user
    signup_user current_user
    redirect_to @job
  end

  def signup_users
    user_ids_to_signup = params.require(:users)
    users_to_signup = []
    user_ids_to_signup.each do |user_id|
      # Check that all user ids are valid
      unless user = User.find_by(id: user_id)
        flash_t :danger, t(".user_not_found", id:user_id)
        redirect_to @job
        return
      end
      users_to_signup << user
    end
    users_to_signup.each { |user| break unless signup_user user }
    redirect_to @job
  end

  def unregister_user
    if user = User.find_by(id: params[:user_id])
      if signup = JobSignup.where(user_id: user.id, job_id: @job.id).first
        signup.destroy
        record_activity :admin_unregister_user_from_job, @job, data: {
          user: user,
          destroyed_job_signup: signup
        }
        flash_t :success, t(".user_unregistered_from_this_job",
                            user_html: user.to_html)
      else
        record_activity :admin_unregister_user_from_job_failed, @job, data: {
          user: user
        }
        flash_t :danger, t(".user_not_signed_up_for_this_job",
                           user_html: user.to_html,
                           job_id:  @job.id)
      end
    else
      flash_t :danger, t(".user_not_found", id: user_id)
    end
    redirect_to @job
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:title, :description, :start_at, :end_at,
                                  :place, :address, :slots, :user_id,
                                  :creation_frequency, :job_type_id, :notes)
    end

    def job_type_param
      job_type_id = params[:job_type]
      return :all if !params.has_key?(:job_type) || job_type_id.blank?
      return nil  if job_type_id == "nil"
      return :all if job_type_id.to_i <= 0
      return job_type_id.to_i_min 1
    end

    def page_query_param
      params[:page].to_i_min 1
    end

    def signup_user(user)
      activity_key = current_user?(user) ? :current_user_sign_up_for_job :
                                           :admin_sign_up_user_for_job
      activity_data = current_user?(user) ? {} : {user: user}
      signup = @job.job_signups.build(user: user,
                                      author: current_user,
                                      allow_past: current_user_admin?)
      if signup.save
        record_activity activity_key, @job, data: activity_data
        return true
      else
        errors = signup.errors[:base].join(" ")
        record_activity activity_key + :_failed, @job,
                        data: activity_data + {errors: errors}
        flash_t :danger, errors
        return false
      end
    end
end
