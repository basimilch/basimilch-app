class JobSignupsController < ApplicationController
  before_action :set_job_signup, only: [:show, :edit, :update, :destroy]

  # GET /job_signups
  # GET /job_signups.json
  def index
    @job_signups = JobSignup.all
  end

  # GET /job_signups/1
  # GET /job_signups/1.json
  def show
  end

  # GET /job_signups/new
  def new
    @job_signup = JobSignup.new
  end

  # GET /job_signups/1/edit
  def edit
  end

  # POST /job_signups
  # POST /job_signups.json
  def create
    @job_signup = JobSignup.new(job_signup_params)

    respond_to do |format|
      if @job_signup.save
        format.html { redirect_to @job_signup, notice: 'Job signup was successfully created.' }
        format.json { render :show, status: :created, location: @job_signup }
      else
        format.html { render :new }
        format.json { render json: @job_signup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /job_signups/1
  # PATCH/PUT /job_signups/1.json
  def update
    respond_to do |format|
      if @job_signup.update(job_signup_params)
        format.html { redirect_to @job_signup, notice: 'Job signup was successfully updated.' }
        format.json { render :show, status: :ok, location: @job_signup }
      else
        format.html { render :edit }
        format.json { render json: @job_signup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_signups/1
  # DELETE /job_signups/1.json
  def destroy
    @job_signup.destroy
    respond_to do |format|
      format.html { redirect_to job_signups_url, notice: 'Job signup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job_signup
      @job_signup = JobSignup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_signup_params
      params.require(:job_signup).permit(:user_id, :job_id)
    end
end
