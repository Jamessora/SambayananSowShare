class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.decimal :total_price
      t.string :status
      t.bigint :buyer_id
      t.bigint :seller_id

      t.timestamps
    end
  end
end
