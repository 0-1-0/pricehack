class CreateEbayOffers < ActiveRecord::Migration
  def change
    create_table :ebay_offers do |t|
      t.string :url

      t.timestamps null: false
    end
  end
end
