class CreateTransactionCrops < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_crops do |t|
      t.references :transaction, null: false, foreign_key: true
      t.references :crop, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price

      t.timestamps
    end
  end
end
