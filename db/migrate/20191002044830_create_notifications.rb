class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.references :question, foreign_key: true
      t.integer :notification_content
      t.integer :notification_status, default: 0

      t.timestamps
    end
  end
end
