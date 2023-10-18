class CreateCrops < ActiveRecord::Migration[7.0]
  def change
    create_table :crops do |t|
      t.string :crop_name
      t.decimal :crop_price
      t.integer :crop_quantity
      t.datetime :crop_expiry_date
      t.string :crop_status

      t.timestamps
    end
  end
end
