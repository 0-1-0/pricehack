class AddProductIdToEbayOffer < ActiveRecord::Migration
  def change
    add_column :ebay_offers, :product_id, :integer
  end
end
