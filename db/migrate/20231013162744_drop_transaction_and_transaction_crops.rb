class DropTransactionAndTransactionCrops < ActiveRecord::Migration[7.0]
  def change
    drop_table :transaction_crops
    drop_table :transactions
  end
end
