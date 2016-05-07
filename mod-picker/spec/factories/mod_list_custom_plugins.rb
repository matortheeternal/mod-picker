# create_table "mod_list_custom_plugins", force: :cascade do |t|
#     t.integer "mod_list_id", limit: 4
#     t.boolean "active"
#     t.integer "index",       limit: 2
#     t.string  "filename",    limit: 64
#     t.text    "description", limit: 65535
#   end

FactoryGirl.define do
  factory :mod_list_custom_plugin do
    association :mod_list_id, factory: :mod_list
    active true
    index { Faker::Number.number(3) }
    filename { Faker::App.name }
    description { Faker::Lorem.sentence(5) }
  end
end
