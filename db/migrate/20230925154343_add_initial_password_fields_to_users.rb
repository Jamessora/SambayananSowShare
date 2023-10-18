class AddInitialPasswordFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :initial_password_token, :string 
    add_column :users, :initial_password_token_sent_at, :datetime
    add_index :users, :initial_password_token, unique: true
  end
end
