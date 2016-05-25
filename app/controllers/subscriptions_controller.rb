class SubscriptionsController < ApplicationController

  # All actions require a logged in user.
  before_action :require_logged_in_user
  before_action :admin_user,  except: [:subscription,
                                       :subscription_edit,
                                       :subscription_update]
  before_action :set_subscription,              only:  [:show,
                                                        :edit,
                                                        :update,
                                                        :destroy,
                                                        :cancel_subscribership]
  before_action :set_current_user_subscription, only:  [:subscription,
                                                        :subscription_edit,
                                                        :subscription_update]

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    if @view = params[:view]
      unless @subscriptions = Subscription.try(@view)
        raise_404
      end
    else
      @subscriptions = Subscription.all
    end
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    unless @subscription.valid_current_items?
      flash_now_t :warning_wrong_total_quantity, I18n.t(
          "errors.messages.wrong_total_quantity_of_current_subscription_items",
          actual_total:   @subscription.current_items_liters.to_s_significant,
          expected_total: @subscription.flexible_milk_liters.to_s_significant)
    end
    if @subscription.without_users?
      flash_now_t :warning_without_users, :no_subscriber_alert
    end
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(subscription_params)

    respond_to do |format|
      if @subscription.save
        record_activity :create, @subscription
        format.html { redirect_to edit_subscription_path(@subscription),
                      notice: 'Subscription was successfully created.' }
        format.json { render :show, status: :created, location: @subscription }
      else
        format.html { render :new }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscriptions/1
  # PATCH/PUT /subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update_with_author(subscription_params, current_user)
        record_activity :update, @subscription
        format.html { redirect_to @subscription, notice: 'Subscription was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to subscriptions_url, notice: 'Subscription was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT /subscriptions/1/cancel_subscribership/1
  def cancel_subscribership
    s_id = params[:subscribership_id]
    if subscribership = @subscription.subscriberships.find_by(id: s_id)
      if subscribership.cancel author: current_user
        flash_t :success, t('.subscribership_successfully_canceled',
                            user: subscribership.user.to_html)
      else
        flash_t :danger, t('.subscribership_not_able_to_be_canceled',
                           user: subscribership.user.to_html)
      end
    else
      flash_t :danger, t('.subcribership_not_found_for_this_subscription',
                         subscribership_id: s_id.inspect)
    end
    redirect_to @subscription
  end

  # GET /subscription
  def subscription
    render :show
  end

  # GET /subscription/edit
  def subscription_edit
    if @subscription.blank?
      redirect_to current_user_subscription_path
    elsif @subscription.can_be_updated_by? current_user
      render :edit
    else
      flash_t :warning, :update_currently_not_possible
      redirect_to current_user_subscription_path
    end
  end

  # PATCH/PUT /subscription
  def subscription_update
    if @subscription.blank?
      redirect_to current_user_subscription_path
    elsif @subscription.update_with_author(subscription_params, current_user)
      record_activity :update, @subscription
      flash_t :success, :update_ok
      redirect_to current_user_subscription_path
    else
      render :edit
    end
  end

  # GET /subscriptions/lists/production
  def production_list
    @order_summary_by_depot = Subscription.order_summary_by_depot
    @product_options = ProductOption.not_canceled
  end

  # GET subscriptions/lists/depot/:depot_id
  def depot_list
    # TODO: Implement
    raise_404
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    def set_current_user_subscription
      @subscription = current_user.subscription
      flash_t :warning, :no_current_user_subscription unless @subscription
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscription_params
      allowed_product_options_keys = ProductOption.not_canceled
                                                  .pluck(:id)
                                                  .map(&:to_s)
      params.require(:subscription).permit(
        # DOC: http://api.rubyonrails.org/v4.2.5.2/classes/ActionController/Parameters.html#method-i-permit
        [:new_items_valid_from,
         item_ids_and_quantities: allowed_product_options_keys] +
         (current_user_admin? ? [:name,
                                 :basic_units,
                                 :supplement_units,
                                 :depot_id,
                                 :notes,
                                 subscriber_user_ids: []] : [])
          )
    end
end
