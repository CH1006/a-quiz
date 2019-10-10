class AddOtherUserToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :other_user, :string
  end
end
