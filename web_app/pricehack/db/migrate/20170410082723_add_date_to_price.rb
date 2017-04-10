class AddDateToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :date, :date
  end
end
