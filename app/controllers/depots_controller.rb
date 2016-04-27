class DepotsController < ApplicationController

  # All actions require a logged in user.
  before_action :require_logged_in_user
  before_action :admin_user#,  except: [:show]
  before_action :set_depot,   only:   [:show, :edit, :update, :destroy,
                                       :cancel, :cancel_coordinator]

  # GET /depots
  # GET /depots.json
  def index
    @depots = Depot.include_canceled(current_user_admin?).by_delivery_time
  end

  # GET /depots/1
  # GET /depots/1.json
  def show
    cancelation_flash @depot
  end

  # GET /depots/new
  def new
    @depot = Depot.new
  end

  # GET /depots/1/edit
  def edit
  end

  # POST /depots
  # POST /depots.json
  def create
    @depot = Depot.new(depot_params)

    respond_to do |format|
      if @depot.save
        format.html { redirect_to @depot, notice: 'Depot was successfully created.' }
        format.json { render :show, status: :created, location: @depot }
      else
        format.html { render :new }
        format.json { render json: @depot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /depots/1
  # PATCH/PUT /depots/1.json
  def update
    logger.warn depot_params.to_s.pink
    respond_to do |format|
      if @depot.update(depot_params)
        format.html { redirect_to @depot, notice: 'Depot was successfully updated.' }
        format.json { render :show, status: :ok, location: @depot }
      else
        format.html { render :edit }
        format.json { render json: @depot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /depots/1
  # DELETE /depots/1.json
  def destroy
    @depot.destroy
    respond_to do |format|
      format.html { redirect_to depots_url, notice: 'Depot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT /depots/1/cancel
  def cancel
    unless @depot.cancel author: current_user
      flash_t :warning, t('.not_able_to_cancel_depot')
    end
    redirect_to @depot
  end

  # PUT /depots/1/cancel_coordinator/1
  def cancel_coordinator
    if (coordinator = @depot.coordinators.find_by id: params[:coordinator_id])&&
          coordinator.cancel(author: current_user)
      record_activity :admin_cancel_depot_coordinator, @depot, data: {
        canceled_coordinator: coordinator,
        user: coordinator.user
      }
    else
      flash_t :danger, t('.unexpected_error_and_coordinator_not_canceled')
    end
    redirect_to @depot
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_depot
      @depot = Depot.find(params[:id])
    end

    PERMITTED_ATTRIBUTES = [:name,
                            :postal_address,
                            :postal_address_supplement,
                            :postal_code,
                            :city,
                            :country,
                            :exact_map_coordinates,
                            :picture,
                            :picture_cache,
                            :directions,
                            :delivery_day,
                            :delivery_time,
                            :opening_hours,
                            :notes,
                            :publish_tel_mobile,
                            :publish_email,
                            # DOC: http://api.rubyonrails.org/v4.2.5.2/classes/ActionController/Parameters.html#method-i-permit
                            # SOURCE: http://stackoverflow.com/a/16555975
                            coordinator_user_ids: [],
                            coordinator_flags: [
                              :publish_tel_mobile,
                              :publish_email
                              ]
                            ]

    # Never trust parameters from the scary internet, only allow the white list through.
    def depot_params
      params.require(:depot).permit(PERMITTED_ATTRIBUTES)
    end
end
