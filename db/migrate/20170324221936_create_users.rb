class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, force: true do |t|
      t.string :ldap_uid, null: false
      t.string :employee_id, null: true
      t.integer :affiliate_id, null: true
      t.integer :student_id, null: true
      t.boolean :superuser_flag, null: false, default: false
      t.boolean :inactive_flag, null: false, default: false
      t.string :first_name, null: true
      t.string :last_name, null: true
      t.string :email, null: true
      t.string :alternate_first_name, null: true
      t.string :alternate_last_name, null: true
      t.string :alternate_email, null: true
      t.boolean :alternate_flag, null: false, default: false
      t.datetime :last_login_at, null: true
      t.timestamps
    end

    add_index :users, :ldap_uid, unique: true
    add_index :users, :employee_id, unique: true
    add_index :users, :affiliate_id, unique: true
    add_index :users, :student_id, unique: true
    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :email
  end
end
