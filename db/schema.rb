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

ActiveRecord::Schema[8.0].define(version: 2025_10_24_210152) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "tb_apolices", primary_key: "numero", force: :cascade do |t|
    t.date "data_emissao", null: false
    t.date "inicio_vigencia", null: false
    t.date "fim_vigencia", null: false
    t.decimal "importancia_segurada", precision: 15, scale: 2, null: false
    t.decimal "lmg", precision: 15, scale: 2, null: false
    t.string "status", null: false
  end

  create_table "tb_endossos", primary_key: "numero", force: :cascade do |t|
    t.integer "tb_apolice_numero", null: false
    t.string "tipo_endosso", null: false
    t.date "data_emissao", null: false
    t.integer "cancelado_endosso_numero"
    t.date "fim_vigencia"
    t.decimal "importancia_segurada", precision: 15, scale: 2
    t.datetime "created_at", null: false
  end

  add_foreign_key "tb_endossos", "tb_apolices", column: "tb_apolice_numero", primary_key: "numero"
  add_foreign_key "tb_endossos", "tb_endossos", column: "cancelado_endosso_numero", primary_key: "numero"
end
