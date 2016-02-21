class JobTypesController < ApplicationController

  before_action :require_logged_in_user
  before_action :admin_user,  except: [:index, :show]
  before_action :set_job_type, only: [:show, :edit, :update, :destroy]

  # GET /job_types
  # GET /job_types.json
  def index
    @job_types = JobType.all
  end

  # GET /job_types/1
  # GET /job_types/1.json
  def show
  end

  # GET /job_types/new
  def new
    @job_type = JobType.new
  end

  # GET /job_types/1/edit
  def edit
  end

  # POST /job_types
  # POST /job_types.json
  def create
    @job_type = JobType.new(job_type_params)

    respond_to do |format|
      if @job_type.save
        format.html { redirect_to @job_type, notice: 'Job type was successfully created.' }
        format.json { render :show, status: :created, location: @job_type }
      else
        format.html { render :new }
        format.json { render json: @job_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /job_types/1
  # PATCH/PUT /job_types/1.json
  def update
    respond_to do |format|
      if @job_type.update(job_type_params)
        format.html { redirect_to @job_type, notice: 'Job type was successfully updated.' }
        format.json { render :show, status: :ok, location: @job_type }
      else
        format.html { render :edit }
        format.json { render json: @job_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_types/1
  # DELETE /job_types/1.json
  def destroy
    @job_type.destroy
    respond_to do |format|
      format.html { redirect_to job_types_url, notice: 'Job type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job_type
      @job_type = JobType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_type_params
      params.require(:job_type).permit(:title, :description, :place, :address, :slots, :user_id)
    end
end
