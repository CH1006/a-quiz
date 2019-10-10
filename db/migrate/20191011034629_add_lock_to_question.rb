class AddLockToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :lock, :boolean, default: false
  end
end
