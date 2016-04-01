  # create_table "masters", id: false, force: :cascade do |t|
  #   t.integer "plugin_id",        limit: 4
  #   t.integer "master_plugin_id", limit: 4
  #   t.integer "index",            limit: 4
  # end

  # add_index "masters", ["plugin_id"], name: "pl_id", using: :btree

FactoryGirl.define do
  factory :master do
    plugin_id 1
    master_plugin_id 2
    index 1
  end
end