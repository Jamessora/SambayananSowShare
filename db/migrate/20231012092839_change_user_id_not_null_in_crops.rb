class ChangeUserIdNotNullInCrops < ActiveRecord::Migration[7.0]
  def change
    change_column_null :crops, :user_id, false
  end
end
