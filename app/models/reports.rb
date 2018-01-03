class Reports

	def journal_reports hub, warehouse

    	stock_account = Account.find_by({'code': :stock})
		 
		if( hub.present?  && warehouse.present? )
	  		@result = ActiveRecord::Base.connection
										.exec_query('select h.name as hub, w.name as warehouse, c.name as commodity, sum(pi.quantity) as balance
							from posting_items pi
							inner join commodities c on c.id = pi.commodity_id
							inner join hubs h on h.id = pi.hub_id
							inner join warehouses w on w.id = pi.warehouse_id
							where pi.account_id = ' + stock_account.id.to_s  + '  and pi.hub_id = ' +   hub.to_s + ' and pi.warehouse_id = ' +  warehouse.to_s + '
							group by hub, warehouse, commodity')
		else
		  	@result = ActiveRecord::Base.connection
		  		.exec_query('')
		end
	end 


	def stock_status_by_commodity_type hub, warehouse
		stock_account = Account.find_by({'code': :stock})
		 
		if( hub.present?  && warehouse.present? )
			@result = StockReportByCommodity.where(:'p_id' => stock_account, :'hub_id' => hub ,:'warehouse_id' => warehouse)
		elsif (hub.present?)
			@result = StockReportByCommodity.where(:'p_id' => stock_account, :'hub_id' => hub)
		else
		  	@result = StockReportByCommodity.where(:'p_id' => stock_account)
		end
	end


	def stock_status_by_project_code hub, warehouse
		stock_account = Account.find_by({'code': :stock})
		if( hub.present?  && warehouse.present? )
	  		@result = ActiveRecord::Base.connection
			.exec_query('select projects.project_code as project_code, commodity_sources.name as commodity_source, hubs.name as hub, warehouses.name as warehouse, commodities.name as commodity, sum(posting_items.quantity) as balance
						from posting_items pi
						inner join projects p on p.id = pi.project_id
						inner join commodity_sources cs on cs.id = p.commodity_source_id
						inner join commodities c on c.id = pi.commodity_id
						inner join hubs h on h.id = pi.hub_id
						inner join warehouses w on w.id = pi.warehouse_id
						where pi.account_id  = ' + stock_account.id.to_s  + '
						and pi.hub_id = ' +   hub.to_s + ' 
						and pi.warehouse_id = ' +  warehouse.to_s + '
						group by commodity_source, hub, warehouse, commodity, project_code')
		elsif (hub.present?)
			@result = ActiveRecord::Base.connection
										.exec_query('select p.project_code as project_code, cs.name as commodity_source, h.name as hub, w.name as warehouse, c.name as commodity, sum(pi.quantity) as balance
													from posting_items pi
													inner join projects p on p.id = pi.project_id
													inner join commodity_sources cs on cs.id = p.commodity_source_id
													inner join commodities c on c.id = pi.commodity_id
													inner join hubs h on h.id = pi.hub_id
													inner join warehouses w on w.id = pi.warehouse_id
													where pi.account_id  = ' + stock_account.id.to_s  + '
													and pi.hub_id = ' +   hub.to_s + ' 
													group by commodity_source, hub, warehouse, commodity, project_code')
		else
		  	@result = ActiveRecord::Base.connection
		  		.exec_query('select p.project_code as project_code, cs.name as commodity_source, h.name as hub, w.name as warehouse, c.name as commodity, sum(pi.quantity) as balance
													from posting_items pi
													inner join projects p on p.id = pi.project_id
													inner join commodity_sources cs on cs.id = p.commodity_source_id
													inner join commodities c on c.id = pi.commodity_id
													inner join hubs h on h.id = pi.hub_id
													inner join warehouses w on w.id = pi.warehouse_id
													where pi.account_id  = ' + stock_account.id.to_s  + '
													group by commodity_source, hub, warehouse, commodity, project_code')
		end
	end
	

	def received_stock_by_project_code (from_date, to_date, hub, warehouse)
		receipt_journal = Journal.find_by({'code': :goods_received})
		stock_account = Account.find_by({'code': :stock})		

		if( from_date.present? && to_date.present? && hub.present?  && warehouse.present? )
			@result = PostingItem.joins(:project, :commodity, :posting).joins("INNER JOIN receipts on receipts.id = postings.document_id").where(journal_id: receipt_journal, account_id: stock_account, hub: hub, warehouse: warehouse).where("receipts.received_Date > ? AND receipts.received_Date < ?", from_date, to_date).group(:'projects.project_code', :'commodities.name').select('projects.project_code, commodities.name, SUM(posting_items.quantity)')
		elsif ( from_date.present? && to_date.present? && hub.present? )
			@result = PostingItem.joins(:project, :commodity, :posting).joins("INNER JOIN receipts on receipts.id = postings.document_id").where(journal_id: receipt_journal, account_id: stock_account, hub: hub).where("receipts.received_Date > ? AND receipts.received_Date < ?", from_date, to_date).group(:'projects.project_code', :'commodities.name').select('projects.project_code, commodities.name, SUM(posting_items.quantity)')
		elsif ( from_date.present? && to_date.present? )
			@result = PostingItem.joins(:project, :commodity, :posting).joins("INNER JOIN receipts on receipts.id = postings.document_id").where(journal_id: receipt_journal, account_id: stock_account).where("receipts.received_Date > ? AND receipts.received_Date < ?", from_date, to_date).group(:'projects.project_code', :'commodities.name').select('projects.project_code, commodities.name, SUM(posting_items.quantity)')
		else
			@result = PostingItem.joins(:project, :commodity).where(journal_id: receipt_journal, account_id: stock_account).group(:'projects.project_code', :'commodities.name').select('projects.project_code, commodities.name, SUM(posting_items.quantity)')
		end
	end

	def received_stock_by_commodity_source (from_date, to_date, hub, warehouse)
		receipt_journal = Journal.find_by({'code': :goods_received})
		stock_account = Account.find_by({'code': :stock})		

		if( from_date.present? && to_date.present? && hub.present?  && warehouse.present? )
			@result = PostingItem.joins(:project, :commodity, :posting).joins("INNER JOIN receipts on receipts.id = postings.document_id INNER JOIN commodity_sources ON commodity_sources.id = receipts.commodity_source_id").where(journal_id: receipt_journal, account_id: stock_account, hub: hub, warehouse: warehouse).where("receipts.received_Date > ? AND receipts.received_Date < ?", from_date, to_date).group(:'commodity_sources.name').select('commodity_sources.name, SUM(posting_items.quantity)')
		elsif ( from_date.present? && to_date.present? && hub.present? )
			@result = PostingItem.joins(:project, :commodity, :posting).joins("INNER JOIN receipts on receipts.id = postings.document_id INNER JOIN commodity_sources ON commodity_sources.id = receipts.commodity_source_id").where(journal_id: receipt_journal, account_id: stock_account, hub: hub).where("receipts.received_Date > ? AND receipts.received_Date < ?", from_date, to_date).group(:'commodity_sources.name').select('commodity_sources.name, SUM(posting_items.quantity)')
		elsif ( from_date.present? && to_date.present? )
			@result = PostingItem.joins(:project, :commodity, :posting).joins("INNER JOIN receipts on receipts.id = postings.document_id INNER JOIN commodity_sources ON commodity_sources.id = receipts.commodity_source_id").where(journal_id: receipt_journal, account_id: stock_account).where("receipts.received_Date > ? AND receipts.received_Date < ?", from_date, to_date).group(:'commodity_sources.name').select('commodity_sources.name, SUM(posting_items.quantity)')
		else
			@result = PostingItem.joins(:project, :commodity, :posting).joins("INNER JOIN receipts on receipts.id = postings.document_id INNER JOIN commodity_sources ON commodity_sources.id = receipts.commodity_source_id").where(journal_id: receipt_journal, account_id: stock_account).group(:'commodity_sources.name').select('commodity_sources.name, SUM(posting_items.quantity)')
		end
	end

	def stock_summary_by_project_code(hub, warehouse)
		stock_account = Account.find_by({'code': :stock})
		if( hub.present?  && warehouse.present? )	
			@result = PostingItem.joins(:project, :commodity).where(account_id: stock_account, hub: hub, warehouse: warehouse).group(:'commodities.id', :'commodities.name', :'project_code').select("projects.project_code as project_code, commodities.id AS commodity_id, commodities.name as commodity, sum(posting_items.quantity) as balance")
		elsif( hub.present? )	
			@result = PostingItem.joins(:project, :commodity).where(account_id: stock_account, hub: hub).group(:'commodities.id', :'commodities.name', :'project_code').select("projects.project_code as project_code, commodities.id AS commodity_id, commodities.name as commodity, sum(posting_items.quantity) as balance")
		else
			@result = PostingItem.joins(:project, :commodity).where(account_id: stock_account).group(:'commodities.id', :'commodities.name', :'project_code').select("projects.project_code as project_code, commodities.id AS commodity_id, commodities.name as commodity, sum(posting_items.quantity) as balance")
		end		
	end
end