class AddKycFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :fullName, :string
    add_column :users, :birthday, :date
    add_column :users, :address, :string
    add_column :users, :idType, :string
    add_column :users, :idNumber, :string
    add_column :users, :idPhoto, :binary
  end
end
