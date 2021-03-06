# == Schema Information
#
# Table name: transporters
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  code              :string           not null
#  vehicle_count     :integer
#  lift_capacity     :decimal(, )
#  capital           :decimal(, )
#  employees         :integer
#  contact           :string
#  contact_phone     :string
#  remark            :text
#  status            :integer          default("active"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by        :integer
#  modified_by       :integer
#  deleted_at        :datetime
#  ownership_type_id :integer
#

class Transporter < ApplicationRecord
  enum ownership: [:plc, :sc, :pvt, :govt, :other]
  enum status: [:active, :inactive]
  enum payment_type: [:check, :bank]
  has_many :transporter_addresses

  validates :name, presence: {message: "  is required!"}  
  validates :name, uniqueness: true

  validates :code, presence: true
  validates :code, uniqueness: true

  def self.amount_requested(transporter_id)

      @amount_requested = 0
      TransportOrder.includes(:transport_order_items).where(:'transport_orders.transporter_id' => transporter_id).each do |to|
        to.transport_order_items.each do |to_item|


                 Delivery.joins(:delivery_details).where({:'deliveries.transporter_id' => transporter_id,
                :'deliveries.requisition_number' => to_item.requisition_no,
                :'deliveries.fdp_id' =>  to_item&.fdp_id, :'deliveries.status' => :verified }).where('delivery_details.received_quantity > 0').
                select(:id, :'delivery_details.received_quantity',:'delivery_details.uom_id',:'delivery_details.loss_quantity',
                :'delivery_details.market_price').find_each do |delivery|
                       
                       @qty_in_ref =   UnitOfMeasure.find(delivery.uom_id).to_ref(delivery.received_quantity)
                        @qtl = UnitOfMeasure.find_by(name: 'Quintal')
                        unit_to_be_changed = UnitOfMeasure.find_by(uom_type: 'ref').name
                        @qty_in_ref =  @qtl.convert_to(unit_to_be_changed,   @qty_in_ref)

                        @loss_amount = @qtl.convert_to(unit_to_be_changed, delivery.loss_quantity.to_f)
                        @loss_cost = @loss_amount * delivery.market_price.to_f 
                        @amount_requested = @amount_requested  + (@qty_in_ref * to_item.tariff) -  @loss_cost
                    end
                end
         end
        return @amount_requested
  end

  def self.fdp_allocations (transporter_id, operation_id, requisition_nos)
    
        @dispatch_summary = []
        Requisition.joins(:commodity, :operation, requisition_items: [:fdp]).where({:'requisitions.operation_id' => operation_id} ).where('requisitions.requisition_no IN (?)',requisition_nos )
        .where('requisition_items.amount > 0').uniq{|t| t.requisition_no }.each do |allocation|          
            allocation.requisition_items.each do |ri|
             @row = Hash.new
            @row['requisition_no'] = allocation&.requisition_no
            @row['commodity'] = allocation&.commodity&.name
            @row['operation_id'] = allocation&.operation_id
            @row['operation'] = allocation&.operation&.name
            @row['fdp_id'] = ri&.fdp&.id
            @row['fdp'] = ri&.fdp&.name
                uom_id = allocation&.operation&.ration&.ration_items.where(commodity_id: allocation.commodity_id)&.first&.unit_of_measure_id
                if(uom_id.present?)
                    @row['allocated_amount'] = UnitOfMeasure.find(uom_id).to_ref(ri.amount)
                else
                    @row['allocated_amount'] = ri.amount
                end
            
           
           
            #dispatch information
            Dispatch.joins(:dispatch_items).where( {:'dispatches.transporter_id' => transporter_id, 
            :'dispatches.operation_id' => operation_id, :'dispatches.requisition_number' => allocation.requisition_no,
            :'fdp_id' =>  ri&.fdp&.id } )
            .select(:id, :'dispatch_items.quantity', :'dispatch_items.unit_of_measure_id').find_each do |di|                    
                @qty_in_ref = UnitOfMeasure.find(di.unit_of_measure_id).to_ref(di.quantity)
                @row['dispatched_amount'] = @row['dispatched_amount'].to_f + @qty_in_ref
            end
           

             # delivery information
                 Delivery.joins(:delivery_details).where({:'deliveries.transporter_id' => transporter_id , :'deliveries.operation_id' => operation_id,
                :'deliveries.requisition_number' => allocation.requisition_no,
                :'deliveries.fdp_id' =>  ri&.fdp&.id }).where('delivery_details.received_quantity > 0').
                select(:id, :'delivery_details.received_quantity',:'delivery_details.uom_id').find_each do |delivery|
                       @qty_in_ref =  UnitOfMeasure.find(delivery.uom_id).to_ref(delivery.received_quantity)
                       @row['delivered_amount'] = @row['delivered_amount'].to_f + @qty_in_ref
                 end

            
            @row['progress'] = ( @row['dispatched_amount'].to_f / @row['allocated_amount'].to_f) * 100
            @dispatch_summary << @row
           
        end
        end
        return @dispatch_summary
    end




     def self.fdp_verification(transporter_id, operation_id, requisition_nos)

        @dispatch_summary = []

         Dispatch.joins(:fdp,:hub,:operation, dispatch_items: [:commodity]).where( {:'dispatches.transporter_id' => transporter_id, 
         :'dispatches.operation_id' => operation_id} ).where('dispatches.requisition_number IN (?)',requisition_nos ).uniq{|t| t.requisition_no }.each do  |di|   

                di.dispatch_items.each do |dispatch_item|
                     @qty_in_ref = UnitOfMeasure.find(dispatch_item.unit_of_measure_id).to_ref(dispatch_item.quantity)
                     @row = Hash.new
                        @row['dispatched_amount'] = @qty_in_ref
                        @row['gin_no']= di.gin_no
                        @row['commodity']=dispatch_item&.commodity&.name
                        @row['operation']=dispatch_item&.dispatch&.operation&.name
                        @row['requisition_no']=dispatch_item&.dispatch&.requisition_number
                        @row['fdp']=dispatch_item&.dispatch&.fdp&.name
                        @row['hub']=dispatch_item&.dispatch&.hub&.name

                # delivery information
                 Delivery.joins(:delivery_details,:operation).where({:'deliveries.transporter_id' => transporter_id, :'deliveries.operation_id' => operation_id,
                :'deliveries.requisition_number' => dispatch_item&.dispatch&.requisition_number,
                :'deliveries.fdp_id' => dispatch_item&.dispatch&.fdp&.id ,:'deliveries.gin_number' => di.gin_no}).where('delivery_details.received_quantity > 0').find_each do |delivery|
                         @row['grn_no'] = delivery.receiving_number     
                         @row['delivery_status'] = delivery.status
                         delivery.delivery_details.each do |dd|
                            # uom_id = delivery&.operation&.ration&.ration_items.where(commodity_id: dd.commodity_id)&.first&.unit_of_measure_id
                            @row['delivery_detail_id'] = dd.id
                            @row['market_price'] = dd.market_price
                            if(dd.uom_id.present?)
                                @row['delivered_amount'] = UnitOfMeasure.find(dd.uom_id).to_ref(dd.received_quantity)
                            else
                                @row['delivered_amount'] = dd.received_quantity
                            end
                            @row['market_price'] = dd.market_price
                        end
                 end

                 #allocation information
                 Requisition.joins(:requisition_items).where({:'requisitions.operation_id' => operation_id,
                 :'requisitions.requisition_no' => dispatch_item&.dispatch&.requisition_number, :'requisition_items.fdp_id' => dispatch_item&.dispatch&.fdp&.id } )
                 .where('requisition_items.amount > 0').find_each do |allocation|
         
                    allocation.requisition_items.each do |ri|
                        uom_id = allocation&.operation&.ration&.ration_items.where(commodity_id: allocation.commodity_id)&.first&.unit_of_measure_id
                        if(uom_id.present?)
                            @row['allocated_amount'] = @row['allocated_amount'].to_f + UnitOfMeasure.find(uom_id).to_ref(ri.amount.to_f)
                        else
                            @row['allocated_amount'] = ri.amount
                        end
                    end
                       @dispatch_summary << @row
                end
            end
            @row['progress'] = ( @row['delivered_amount'].to_f / @row['dispatched_amount'].to_f) * 100
            @row['can_verify'] = true
            @row['loss_amount'] = @row['dispatched_amount'].to_f - @row['delivered_amount'].to_f
            if (@row['loss_amount'] > 1 && (! (@row['market_price'].present?)))
                @row['can_verify'] = false
            end
        end
        return @dispatch_summary
    end
    
   def self.dispatches_list_per_fdp (transporter_id, operation_id, requisition_no, fdp_id)
        @dispatch_summary = []
        #dispatch information
        DispatchItem.joins(:dispatch, :commodity).where( {:'dispatches.transporter_id' => transporter_id, :'dispatches.operation_id' => operation_id, :'dispatches.requisition_number' => requisition_no, :'dispatches.fdp_id' =>  fdp_id } ).find_each do |di|       

            @row = Hash.new
            @row['gin_no'] = di.dispatch.gin_no
            @row['commodity'] = di.commodity.name
            @row['dispatch_date'] = di.dispatch.dispatch_date
            @qty_in_ref = UnitOfMeasure.find(di.unit_of_measure_id).to_ref(di.quantity)
            @row['dispatched_amount'] = @row['dispatched_amount'].to_f + @qty_in_ref
            @row['delivered_amount'] = 0
            # delivery information
            Delivery.joins(:delivery_details).where({:'deliveries.transporter_id' => transporter_id , :'deliveries.operation_id' => operation_id, :'deliveries.requisition_number' => requisition_no, :'deliveries.fdp_id' =>  fdp_id,:'deliveries.gin_number' => di.dispatch.gin_no }).where('delivery_details.received_quantity > 0').select(:id, :'delivery_details.received_quantity',:'delivery_details.uom_id').find_each do |delivery|
                @qty_in_ref =  UnitOfMeasure.find(delivery.uom_id).to_ref(delivery.received_quantity)
                @row['delivered_amount'] = @row['delivered_amount'] + @qty_in_ref
            end
            @row['progress'] = ( @row['delivered_amount'].to_f / @row['dispatched_amount'].to_f) * 100
            @dispatch_summary << @row
        end 
        return @dispatch_summary       
    end
end
