# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_07_231505) do

  create_table "impersonations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "target_id", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_id"], name: "index_impersonations_on_target_id"
    t.index ["user_id"], name: "index_impersonations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "ldap_uid", null: false
    t.string "employee_id"
    t.string "affiliate_id"
    t.string "student_id"
    t.boolean "superuser_flag", default: false, null: false
    t.boolean "inactive_flag", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "alternate_first_name"
    t.string "alternate_last_name"
    t.string "alternate_email"
    t.boolean "alternate_flag", default: false, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_id"], name: "index_users_on_affiliate_id", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["employee_id"], name: "index_users_on_employee_id", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["ldap_uid"], name: "index_users_on_ldap_uid", unique: true
    t.index ["student_id"], name: "index_users_on_student_id", unique: true
  end

end
