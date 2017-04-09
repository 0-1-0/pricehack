class AddEbayOfferIdToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :ebay_offer_id, :integer
  end
end
