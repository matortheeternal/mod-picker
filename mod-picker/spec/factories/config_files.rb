# create_table "config_files", force: :cascade do |t|
#   t.integer "game_id",         limit: 4,                 null: false
#   t.string  "filename",        limit: 64,                null: false
#   t.string  "install_path",    limit: 128,               null: false
#   t.text    "text_body",       limit: 65535
#   t.integer "mod_lists_count", limit: 4,     default: 0, null: false
# end

FactoryGirl.define do
  factory :config_file do
    association :game, factory: :game 
    filename {Faker::App.name}
    install_path {Faker::App.name}
  end
end
