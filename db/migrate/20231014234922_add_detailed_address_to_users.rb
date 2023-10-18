class AddDetailedAddressToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :address_country, :string
    add_column :users, :address_city, :string
    add_column :users, :address_baranggay, :string
    add_column :users, :address_street, :string
    remove_column :users, :address, :string
  end
end
