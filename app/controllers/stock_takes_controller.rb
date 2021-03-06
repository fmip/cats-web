class StockTakesController < ApplicationController
  
  before_action :set_stock_take, only: [:show, :edit, :update, :destroy]
  before_action :authorize_stock_take
  # GET /stock_takes
  # GET /stock_takes.json
  def index
    @stock_takes = StockTake.all
  end

  # GET /stock_takes/1
  # GET /stock_takes/1.json
  def show
  end

  # GET /stock_takes/new
  def new
    @stock_take = StockTake.new
    @stores = Store.order(:name)
    @warehouses = Warehouse.all
  end

  # GET /stock_takes/1/edit
  def edit
    @stores = Store.order(:name)
    @warehouses = Warehouse.all
  end

  # POST /stock_takes
  # POST /stock_takes.json
  def create
    @stock_take = StockTake.new(stock_take_params)
    @warehouses = Warehouse.all
    @stores = Store.order(:name)

    respond_to do |format|
      if @stock_take.save
        format.html { redirect_to @stock_take, notice: 'Stock take was successfully created.' }
        format.json { render :show, status: :created, location: @stock_take }
      else
        format.html { render :new }
        format.json { render json: @stock_take.errors, status: :unprocessable_entity }
      end
    end
  end

  def post_stock_take
    @stock_take = StockTake.find(params[:id])    
    @stock_take.draft = false
     respond_to do |format|
      if @stock_take.save
        format.html { redirect_to @stock_take, notice: 'Stock take was successfully created.' }
        format.json { render :show, status: :created, location: @stock_take }
      else
        format.html { render :new }
        format.json { render json: @stock_take.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_takes/1
  # PATCH/PUT /stock_takes/1.json
  def update
    @warehouses = Warehouse.all
    @stores = Store.order(:name)
    respond_to do |format|
      if @stock_take.update(stock_take_params)
        format.html { redirect_to @stock_take, notice: 'Stock take was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock_take }
      else
        format.html { render :edit }
        format.json { render json: @stock_take.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_takes/1
  # DELETE /stock_takes/1.json
  def destroy
    @stock_take.destroy
    respond_to do |format|
      format.html { redirect_to stock_takes_url, notice: 'Stock take was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def authorize_stock_take
    authorize StockTake 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_take
      @stock_take = StockTake.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_take_params
      params.require(:stock_take).permit(:title, :hub_id, :warehouse_id, :store_no, :date)
    end
end
