class AddBuyerAndSellerToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :buyer_id, :bigint, null: false
    add_column :transactions, :seller_id, :bigint, null: false
  end
end
