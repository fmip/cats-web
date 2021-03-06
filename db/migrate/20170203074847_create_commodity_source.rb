class CreateCommoditySource < ActiveRecord::Migration[5.0]
  def change
    create_table :commodity_sources do |t|
      t.string :name

      t.integer :created_by
      t.integer :modified_by
      t.boolean :deleted, :default => false
      t.datetime :deleted_at

      t.timestamps 
    end
  end
end
