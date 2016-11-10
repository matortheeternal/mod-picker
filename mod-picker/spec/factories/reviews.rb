
  # create_table "reviews", force: :cascade do |t|
  #   t.integer  "submitted_by",          limit: 4
  #   t.integer  "mod_id",                limit: 4
  #   t.boolean  "hidden"
  #   t.integer  "rating1",               limit: 1
  #   t.integer  "rating2",               limit: 1
  #   t.integer  "rating3",               limit: 1
  #   t.integer  "rating4",               limit: 1
  #   t.integer  "rating5",               limit: 1
  #   t.datetime "submitted"
  #   t.datetime "edited"
  #   t.text     "text_body",             limit: 65535
  #   t.integer  "corrections_count", limit: 4,     default: 0
  #   t.integer  "review_template_id",    limit: 4
  # end

  # Validations
  # validates :review_template_id, :mod_id, :rating1, :text_body, presence: true
  # validates :hidden, inclusion: [true, false]
  # validates :rating1, :rating2, :rating3, :rating4, :rating5, length: {in: 0..100}
  # validates :text_body, length: {in: 255..32768}
FactoryGirl.define do
  factory :review do
    association :mod, factory: :mod
    association :review_template, factory: :review_template
    rating1 { Faker::Number.between(1, 100)}
    text_body { Faker::Lorem.paragraph(10, false, 10) }
  end
end