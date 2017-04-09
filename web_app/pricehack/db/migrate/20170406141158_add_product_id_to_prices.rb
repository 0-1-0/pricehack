class AddProductIdToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :product_id, :integer
  end
end
