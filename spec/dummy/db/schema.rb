# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170324221936) do

  create_table "users", force: :cascade do |t|
    t.string "ldap_uid", null: false
    t.string "employee_id"
    t.integer "affiliate_id"
    t.integer "student_id"
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
