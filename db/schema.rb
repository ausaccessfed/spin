# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150121002347) do

  create_table "api_subject_roles", force: true do |t|
    t.integer  "api_subject_id", null: false
    t.integer  "role_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_subject_roles", ["api_subject_id", "role_id"], name: "index_api_subject_roles_on_api_subject_id_and_role_id", unique: true, using: :btree
  add_index "api_subject_roles", ["api_subject_id"], name: "index_api_subject_roles_on_api_subject_id", using: :btree
  add_index "api_subject_roles", ["role_id"], name: "index_api_subject_roles_on_role_id", using: :btree

  create_table "api_subjects", force: true do |t|
    t.string   "x509_cn",                     null: false
    t.string   "description",  default: "",   null: false
    t.string   "contact_name",                null: false
    t.string   "contact_mail",                null: false
    t.boolean  "enabled",      default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_subjects", ["x509_cn"], name: "index_api_subjects_on_x509_cn", unique: true, using: :btree

  create_table "audits", force: true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "aws_session_instances", force: true do |t|
    t.integer  "subject_id",      null: false
    t.integer  "project_role_id", null: false
    t.string   "identifier",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisations", force: true do |t|
    t.string   "name",        null: false
    t.string   "external_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisations", ["external_id"], name: "index_organisations_on_external_id", unique: true, using: :btree

  create_table "permissions", force: true do |t|
    t.integer  "role_id",    null: false
    t.string   "value",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["role_id", "value"], name: "index_permissions_on_role_id_and_value", unique: true, using: :btree
  add_index "permissions", ["role_id"], name: "index_permissions_on_role_id", using: :btree

  create_table "project_roles", force: true do |t|
    t.string   "name",       null: false
    t.string   "role_arn",   null: false
    t.integer  "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_roles", ["project_id"], name: "index_project_roles_on_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",            null: false
    t.string   "provider_arn",    null: false
    t.string   "state",           null: false
    t.integer  "organisation_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_project_roles", force: true do |t|
    t.integer  "subject_id",      null: false
    t.integer  "project_role_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_project_roles", ["project_role_id"], name: "index_subject_project_roles_on_project_role_id", using: :btree
  add_index "subject_project_roles", ["subject_id", "project_role_id"], name: "index_subject_project_roles_on_subject_id_and_project_role_id", unique: true, using: :btree
  add_index "subject_project_roles", ["subject_id"], name: "index_subject_project_roles_on_subject_id", using: :btree

  create_table "subject_roles", force: true do |t|
    t.integer  "subject_id", null: false
    t.integer  "role_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_roles", ["role_id"], name: "index_subject_roles_on_role_id", using: :btree
  add_index "subject_roles", ["subject_id", "role_id"], name: "index_subject_roles_on_subject_id_and_role_id", unique: true, using: :btree
  add_index "subject_roles", ["subject_id"], name: "index_subject_roles_on_subject_id", using: :btree

  create_table "subject_sessions", force: true do |t|
    t.string   "remote_host"
    t.string   "remote_addr",     null: false
    t.string   "http_user_agent"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_sessions", ["subject_id"], name: "index_subject_sessions_on_subject_id", using: :btree

  create_table "subjects", force: true do |t|
    t.string   "name",                         null: false
    t.string   "mail",                         null: false
    t.string   "targeted_id"
    t.string   "shared_token"
    t.boolean  "complete",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",      default: true,  null: false
  end

  add_index "subjects", ["mail"], name: "index_subjects_on_mail", unique: true, using: :btree
  add_index "subjects", ["shared_token"], name: "index_subjects_on_shared_token", unique: true, using: :btree
  add_index "subjects", ["targeted_id"], name: "index_subjects_on_targeted_id", using: :btree

end
