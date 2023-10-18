class AddConfirmableToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :confirmation_token, :string
    add_column :admins, :confirmed_at, :datetime
    add_column :admins, :confirmation_sent_at, :datetime
    add_column :admins, :unconfirmed_email, :string
  end
end
