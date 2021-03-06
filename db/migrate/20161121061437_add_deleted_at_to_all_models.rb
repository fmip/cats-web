class AddDeletedAtToAllModels < ActiveRecord::Migration[5.0]
  def change

  		[
				:accounts,
				:bid_plan_items,
				:bid_plans,
				:bid_submissions,
				:bid_winners,
				:commodity_categories,
				:commodities,
				:contracts,
				:currencies,
				:donors,
				:fdp_contacts,
				:fdps,
				:fscd_annual_plans,
				:fscd_plan_items,
				:fund_sources,
				:fund_types,
				:gift_certificate_items,
				:gift_certificates,
				:hrd_items,
				:hrds,
				:hubs,
				:locations,
				:mode_of_transports,
				:operations,
        :organizations,
				:programs,
				:quotations,
				:ration_items,
				:rations,
				:requisition_items,
				:requisitions,
				:seasons,
				:warehouses,
				:stores,
				:transporter_addresses,
				:transporters,
				:transport_order_items,
				:transport_orders,
				:transport_requisition_items,
				:transport_requisitions,
				:unit_of_measures,
				:uom_categories,
				:users
				].each do |table|

		    add_column table, :deleted_at, :datetime
		    add_index table, :deleted_at
		end
  end
end
