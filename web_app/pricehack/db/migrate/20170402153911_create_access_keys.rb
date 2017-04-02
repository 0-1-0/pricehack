class CreateAccessKeys < ActiveRecord::Migration
  def change
    create_table :access_keys do |t|
      t.string :provider
      t.string :key
      t.string :secret

      t.timestamps null: false
    end
  end
end
