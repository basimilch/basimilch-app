class ShareCertificatesController < ApplicationController

  # All actions require a logged in admin user.
  before_action :require_logged_in_user
  before_action :admin_user
  before_action :set_share_certificate, only: [:show, :edit, :update, :destroy]


  # GET /share_certificates
  # GET /share_certificates.json
  def index
    @share_certificates = ShareCertificate.all
  end

  # GET /share_certificates/1
  # GET /share_certificates/1.json
  def show
  end

  # GET /share_certificates/new
  def new
    @user_id = params[:user_id]
    @share_certificate = ShareCertificate.new(user_id: @user_id)
  end

  # GET /share_certificates/1/edit
  def edit
  end

  # POST /share_certificates
  # POST /share_certificates.json
  def create
    @share_certificate = ShareCertificate.new(share_certificate_params)

    respond_to do |format|
      if @share_certificate.save
        record_activity :create, @share_certificate
        format.html { redirect_to @share_certificate, notice: 'Share certificate was successfully created.' }
        format.json { render :show, status: :created, location: @share_certificate }
      else
        format.html { render :new }
        format.json { render json: @share_certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /share_certificates/1
  # PATCH/PUT /share_certificates/1.json
  def update
    respond_to do |format|
      if @share_certificate.update(share_certificate_params)
        record_activity :update, @share_certificate
        format.html { redirect_to @share_certificate, notice: 'Share certificate was successfully updated.' }
        format.json { render :show, status: :ok, location: @share_certificate }
      else
        format.html { render :edit }
        format.json { render json: @share_certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /share_certificates/1
  # DELETE /share_certificates/1.json
  def destroy
    record_activity :destroy, @share_certificate # Must come before the destroy action.
    @share_certificate.destroy
    respond_to do |format|
      format.html { redirect_to share_certificates_url, notice: 'Share certificate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_share_certificate
      @share_certificate = ShareCertificate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def share_certificate_params
      params.require(:share_certificate).permit(:user_id, :sent_at, :payed_at, :returned_at, :notes)
    end
end
