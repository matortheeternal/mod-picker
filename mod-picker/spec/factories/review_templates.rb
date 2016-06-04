# create_table "review_templates", force: :cascade do |t|
#   t.string   "name",         limit: 255, null: false
#   t.integer  "submitted_by", limit: 4,   null: false
#   t.datetime "submitted"
#   t.datetime "edited"
#   t.string   "section1",     limit: 32,  null: false
#   t.string   "section2",     limit: 32
#   t.string   "section3",     limit: 32
#   t.string   "section4",     limit: 32
#   t.string   "section5",     limit: 32
# end


#   Validations
#   validates :name, :section1, presence: true
#   validates :name, length: {in: 4..32}
#   validates :section1, :section2, :section3, :section4, :section5, length: {in: 2..32}

FactoryGirl.define do
  factory :review_template do
    association :user, factory: :user
    name { Faker::Company.name[1..32] }
    section1 { Faker::Lorem.sentence(1)[1..32] }
  end
end