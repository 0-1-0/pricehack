class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :amazon_id

      t.timestamps null: false
    end
  end
end
