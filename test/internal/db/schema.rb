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

ActiveRecord::Schema.define do
  create_table "thing_with_custom_unit_accessors", force: :cascade do |t|
    t.decimal  "length_value",                  precision: 10, scale: 2
    t.decimal  "width_value",                   precision: 10, scale: 2
    t.decimal  "height_value",                  precision: 10, scale: 2
    t.decimal  "volume_value",                  precision: 10, scale: 2
    t.string   "volume_unit",          limit: 12
    t.string   "size_unit",          limit: 12
    t.decimal  "total_weight_value",            precision: 10, scale: 2, default: "10.0"
    t.decimal  "extra_weight_value",            precision: 10, scale: 2
    t.string   "weight_unit",        limit: 12
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
  end

  create_table "things", force: :cascade do |t|
    t.decimal  "length_value",                                   precision: 10, scale: 2
    t.string   "length_unit",                         limit: 12
    t.decimal  "width_value",                                    precision: 10, scale: 2
    t.string   "width_unit",                          limit: 12
    t.decimal  "height_value",                                   precision: 10, scale: 2
    t.string   "height_unit",                         limit: 12
    t.decimal  "volume_value",                                   precision: 10, scale: 2
    t.string   "volume_unit",                         limit: 12
    t.decimal  "total_weight_value",                             precision: 10, scale: 2, default: "10.0"
    t.string   "total_weight_unit",                   limit: 12,                          default: "g"
    t.decimal  "extra_weight_value",                             precision: 10, scale: 2
    t.string   "extra_weight_unit",                   limit: 12
    t.decimal  "length_with_max_on_assignment_value",            precision: 10, scale: 2
    t.string   "length_with_max_on_assignment_unit",  limit: 12
    t.datetime "created_at",                                                                               null: false
    t.datetime "updated_at",                                                                               null: false
  end

  create_table "validated_things", force: :cascade do |t|
    t.decimal  "length_value",                                               precision: 10, scale: 2
    t.string   "length_unit",                                     limit: 12
    t.decimal  "length_true_value",                                          precision: 10, scale: 2
    t.string   "length_true_unit",                                limit: 12
    t.decimal  "length_message_value",                                       precision: 10, scale: 2
    t.string   "length_message_unit",                             limit: 12
    t.decimal  "length_message_from_block_value",                            precision: 10, scale: 2
    t.string   "length_message_from_block_unit",                  limit: 12
    t.decimal  "length_units_value",                                         precision: 10, scale: 2
    t.string   "length_units_unit",                               limit: 12
    t.decimal  "length_units_singular_value",                                precision: 10, scale: 2
    t.string   "length_units_singular_unit",                      limit: 12
    t.decimal  "length_presence_value",                                      precision: 10, scale: 2
    t.string   "length_presence_unit",                            limit: 12
    t.decimal  "length_invalid_value",                                       precision: 10, scale: 2
    t.string   "length_invalid_unit",                             limit: 12
    t.datetime "created_at",                                                                          null: false
    t.datetime "updated_at",                                                                          null: false
    t.decimal  "length_numericality_inclusive_value",                        precision: 10, scale: 2
    t.string   "length_numericality_inclusive_unit",              limit: 12
    t.decimal  "length_numericality_exclusive_value",                        precision: 10, scale: 2
    t.string   "length_numericality_exclusive_unit",              limit: 12
    t.decimal  "length_numericality_equality_value",                         precision: 10, scale: 2
    t.string   "length_numericality_equality_unit",               limit: 12
    t.decimal  "length_invalid_comparison_value",                            precision: 10, scale: 2
    t.string   "length_invalid_comparison_unit",                  limit: 12
    t.decimal  "length_non_zero_scalar_value",                               precision: 10, scale: 2
    t.string   "length_non_zero_scalar_unit",                     limit: 12
    t.decimal  "length_zero_scalar_value",                                   precision: 10, scale: 2
    t.string   "length_zero_scalar_unit",                         limit: 12
    t.decimal  "length_numericality_less_than_than_scalar_value",            precision: 10, scale: 2
    t.string   "length_numericality_less_than_than_scalar_unit",  limit: 12
  end

  create_table "thing_with_custom_value_accessors", force: :cascade do |t|
    t.decimal  "custom_length",                  precision: 10, scale: 2
    t.string   "length_unit",         limit: 12
    t.decimal  "custom_width",                   precision: 10, scale: 2
    t.string   "width_unit",          limit: 12
    t.decimal  "custom_height",                  precision: 10, scale: 2
    t.string   "height_unit",         limit: 12
    t.decimal  "custom_volume",                  precision: 10, scale: 2
    t.string   "volume_unit",         limit: 12
    t.decimal  "custom_weight",                  precision: 10, scale: 2, default: "10.0"
    t.string   "total_weight_unit",   limit: 12
    t.decimal  "custom_extra_weight",            precision: 10, scale: 2
    t.string   "extra_weight_unit",   limit: 12
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
  end

end
