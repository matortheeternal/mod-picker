  # create_table "install_order_notes", force: :cascade do |t|
  #   t.integer  "submitted_by",   limit: 4,     null: false
  #   t.integer  "install_first",  limit: 4,     null: false
  #   t.integer  "install_second", limit: 4,     null: false
  #   t.datetime "submitted"
  #   t.datetime "edited"
  #   t.text     "text_body",      limit: 65535
  # end

FactoryGirl.define do
  factory :install_order_note do
    submitted_by { FactoryGirl.create(:user).id }
    first_mod_id { FactoryGirl.create(:mod).id }
    second_mod_id { FactoryGirl.create(:mod).id }
    text_body { Faker::Lorem.sentence(70, false, 6) }
    game_id {FactoryGirl.create(:game).id }
  end
end