class DepotsController < ApplicationController

  # All actions require a logged in user.
  before_action :require_logged_in_user
  before_action :admin_user,  except: [:depot]
  before_action :set_depot,   only:   [:show, :edit, :update, :destroy,
                                       :cancel, :cancel_coordinator]
  before_action :set_current_user_depot, only:  [:depot]

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

  # GET /depot
  def depot
    render 'show'
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
        record_activity :create, @depot
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
    respond_to do |format|
      if @depot.update(depot_params)
        record_activity :update, @depot
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
    record_activity :destroy, @depot # Must come before the destroy action.
    unless @depot.destroy
      record_activity :destroy_failed, @depot
    end
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

    def set_current_user_depot
      @depot = current_user.depot
      flash_t :warning, :no_current_user_depot unless @depot
    end

    PERMITTED_ATTRIBUTES = [:name,
                            :postal_address,
                            :postal_address_supplement,
                            :postal_code,
                            :city,
                            :country,
                            :exact_map_coordinates,
                            # :picture,
                            :directions,
                            :delivery_day,
                            :delivery_time,
                            :opening_hours,
                            :notes,
                            :publish_tel_mobile,
                            :publish_email,
                            # DOC: http://api.rubyonrails.org/v5.2.0/classes/ActionController/Parameters.html#method-i-permit
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
