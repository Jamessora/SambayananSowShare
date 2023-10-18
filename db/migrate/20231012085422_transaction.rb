class Transaction < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total_price
      t.string :status # such as 'pending', 'completed', etc.

      t.timestamps
    end
  end
end
