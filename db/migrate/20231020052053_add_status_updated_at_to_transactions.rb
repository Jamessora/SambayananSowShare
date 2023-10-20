class AddStatusUpdatedAtToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :status_updated_at, :datetime
  end
end
