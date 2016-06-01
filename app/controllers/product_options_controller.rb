class ProductOptionsController < ApplicationController

  before_action :require_logged_in_user
  before_action :admin_user#,  except: [:index, :show]
  before_action :set_product_option, only: [:show, :edit, :update, :destroy,
                                            :cancel]

  # GET /product_options
  # GET /product_options.json
  def index
    @product_options = ProductOption.all
  end

  # GET /product_options/1
  # GET /product_options/1.json
  def show
    cancelation_flash @product_option
  end

  # GET /product_options/new
  def new
    @product_option = ProductOption.new
  end

  # GET /product_options/1/edit
  def edit
  end

  # POST /product_options
  # POST /product_options.json
  def create
    @product_option = ProductOption.new(product_option_params)
    respond_to do |format|
      if @product_option.save
        record_activity :create, @product_option
        format.html { redirect_to @product_option, notice: 'Product option was successfully created.' }
        format.json { render :show, status: :created, location: @product_option }
      else
        format.html { render :new }
        format.json { render json: @product_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_options/1
  # PATCH/PUT /product_options/1.json
  def update
    respond_to do |format|
      if @product_option.update(product_option_params)
        record_activity :update, @product_option
        format.html { redirect_to @product_option, notice: 'Product option was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_option }
      else
        format.html { render :edit }
        format.json { render json: @product_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /product_option/1/cancel
  def cancel
    @product_option.cancel author: current_user
    redirect_to @product_option
  end

  # DELETE /product_options/1
  # DELETE /product_options/1.json
  def destroy
    record_activity :destroy, @product_option # Must come before the destroy action.
    unless @product_option.destroy
      record_activity :destroy_failed, @product_option
    end
    respond_to do |format|
      format.html { redirect_to product_options_url, notice: 'Product option was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_option
      @product_option = ProductOption.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_option_params
      params.require(:product_option).permit(:name,
                                             :description,
                                             # :picture,
                                             :size,
                                             :size_unit,
                                             :equivalent_in_milk_liters,
                                             :notes)
    end
end
