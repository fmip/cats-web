class TransportersController < ApplicationController
  before_action :set_transporter, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  # GET /transporters
  # GET /transporters.json
  def index
    @transporters = Transporter.all
  end

  # GET /transporters/1
  # GET /transporters/1.json
  def show
    @transport_order_items = TransportOrderItem.joins(transport_order: [:operation]).
    joins("LEFT OUTER JOIN bids b on b.id =transport_orderS.bid_id LEFT OUTER JOIN bid_winners bw on bw.bid_id = b.id")
    .where(:'transport_orders.transporter_id' => params[:id],
     :'transport_orders.status'=> :draft) #here status has to be changed to :ongoing
    .group(:'transport_order_items.transport_order_id', :'operations.id',:'transport_orders.order_no')
    .select('operations.id as operation_id, sum(bw.tariff_amount) as tarrif_amount, sum(transport_order_items.quantity) as balance, transport_order_items.transport_order_id, transport_orders.order_no as order_no,operations.name as operation')
end

def transporter_fdp_detail
    @requisitions = TransportOrderItem.joins(transport_order: [:operation])
    .where(:'transport_orders.id' => params[:order_id], 
    :'transport_orders.transporter_id' => params[:transporter_id], 
    :'transport_orders.operation_id' => params[:operation_id]).distinct.pluck(:requisition_no)
     @dispatch_summary = Transporter.fdp_allocations(params[:transporter_id], params[:operation_id], @requisitions)  
     @transporter = Transporter.find(params[:transporter_id])
     @order_no = TransportOrder.find(params[:order_id]).order_no
end

def transporter_verify_detail
   @requisitions = TransportOrderItem.joins(transport_order: [:operation])
    .where(:'transport_orders.id' => params[:order_id], 
    :'transport_orders.transporter_id' => params[:transporter_id], 
    :'transport_orders.operation_id' => params[:operation_id]).pluck(:requisition_no)
     @dispatch_summary = Transporter.fdp_verification(params[:transporter_id], params[:operation_id], @requisitions)  
     @transporter = Transporter.find(params[:transporter_id])
     @order_no = TransportOrder.find(params[:order_id]).order_no
end

  # GET /transporters/new
  def new
    @transporter = Transporter.new
  end

  # GET /transporters/1/edit
  def edit
  end

  # POST /transporters
  # POST /transporters.json
  def create
    @transporter = Transporter.new(transporter_params)
    @transporter.created_by = current_user.id
    respond_to do |format|
      if @transporter.save
        format.html { redirect_to transporters_path, notice: 'Transporter was successfully created.' }
        format.json { render :show, status: :created, location: @transporter }
      else
        format.html { render :new }
        format.json { render json: @transporter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transporters/1
  # PATCH/PUT /transporters/1.json
  def update
    respond_to do |format|
      @transporter.modified_by = current_user.id
      if @transporter.update(transporter_params)
        format.html { redirect_to transporter_path @transporter, notice: 'Transporter was successfully updated.' }
        format.json { render :show, status: :ok, location: @transporter }
      else
        format.html { render :edit }
        format.json { render json: @transporter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transporters/1
  # DELETE /transporters/1.json
  def destroy
    @transporter.destroy
    respond_to do |format|
      format.html { redirect_to transporters_url, notice: 'Transporter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_transporter
    @transporter = Transporter.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def transporter_params
    params.require(:transporter).permit(:name, :code, :ownership_type_id, :vehicle_count, :lift_capacity, :capital, :employees, :contact, :contact_phone, :remark, :status)
  end
end
