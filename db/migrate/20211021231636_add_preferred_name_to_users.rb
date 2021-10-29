class AddPreferredNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :preferred_first_name, :string, null: true
    add_column :users, :preferred_last_name, :string, null: true

    add_index :users, :preferred_first_name
    add_index :users, :preferred_last_name
  end
end
