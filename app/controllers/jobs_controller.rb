class JobsController < ApplicationController

  before_action :require_logged_in_user
  before_action :admin_user,  except: [:index, :show, :signup_current_user]
  before_action :set_job,     only:   [:show, :edit, :update, :destroy,
                                       :signup_current_user]

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.future
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
      @job = original_job.dup
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
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
      else
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
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def signup_current_user
    signup = @job.job_signups.build(user_id: current_user.id)
    if signup.save
      logger.info "Successfully signed up #{current_user} for #{@job}."
    else
      logger.info "Not possible to sign up #{current_user} for #{@job}."
      flash_t :danger, signup.errors[:base].join(" ")
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
                                  :place, :address, :slots, :user_id)
    end
end
