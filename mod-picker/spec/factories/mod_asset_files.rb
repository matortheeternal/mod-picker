# create_table "mod_asset_files", force: :cascade do |t|
#     t.string "filepath", limit: 128, null: false
#   end

#   add_index "mod_asset_files", ["filepath"], name: "filepath", unique: true, using: :btree
  
FactoryGirl.define do
  factory :mod_asset_file do
    filepath "filepath"
  end

end
