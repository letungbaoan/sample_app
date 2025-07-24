class ChangeGenderToStringInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :gender, :integer
  end
end
