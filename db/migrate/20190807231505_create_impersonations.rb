class CreateImpersonations < ActiveRecord::Migration[5.2]
  def change
    create_table :impersonations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :target, null: false, foreign_key: { to_table: :users }
      t.boolean :active, null: false, default: false
      t.timestamps
    end
  end
end
