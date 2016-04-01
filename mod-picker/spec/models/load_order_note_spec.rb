require 'rails_helper'

# create_table "load_order_notes", force: :cascade do |t|
#     t.integer  "submitted_by", limit: 4,     null: false
#     t.integer  "load_first",   limit: 4,     null: false
#     t.integer  "load_second",  limit: 4,     null: false
#     t.datetime "submitted"
#     t.datetime "edited"
#     t.text     "text_body",    limit: 65535
#   end

#   add_index "load_order_notes", ["load_first"], name: "fk_rails_d6c931c1cc", using: :btree
#   add_index "load_order_notes", ["load_second"], name: "fk_rails_af9e3c9509", using: :btree
#   add_index "load_order_notes", ["submitted_by"], name: "fk_rails_9992d700a9", using: :btree

RSpec.describe LoadOrderNote, :model, :wip do
  it "should have a valid factory" do
    expect(build(:load_order_note)).to be_valid
  end
end