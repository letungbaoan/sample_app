class AddIndexToMicropostsUserCreatedAt < ActiveRecord::Migration[7.0]
  def change
    add_index :microposts, [:user_id, :created_at]
  end
end
