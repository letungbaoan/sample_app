class ChangeGenderToStringInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :gender, :integer, using: 'CAST(gender AS INTEGER)'
  end
end
