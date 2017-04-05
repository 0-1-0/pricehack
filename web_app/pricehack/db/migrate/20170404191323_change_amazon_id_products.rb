class ChangeAmazonIdProducts < ActiveRecord::Migration
  def change
    change_column :products, :amazon_id, :string
  end
end
