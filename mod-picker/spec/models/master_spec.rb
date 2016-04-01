require 'rails_helper'

  # create_table "masters", id: false, force: :cascade do |t|
  #   t.integer "plugin_id",        limit: 4
  #   t.integer "master_plugin_id", limit: 4
  #   t.integer "index",            limit: 4
  # end

  # add_index "masters", ["plugin_id"], name: "pl_id", using: :btree


RSpec.describe Master, :model, :wip do
  it "should have a valid factory" do
    expect(build(:master)).to be_valid 
  end

  context "validations" do
    describe "plugin_id" do
      it "should be invalid if blank" do
        master = build(:master,
          plugin_id: nil)

        master.valid?
        expect(master.errors[:plugin_id]).to include("can't be blank")
      end
    end

    describe "master_plugin_id" do
      it "should be invalid if blank" do
        master = build(:master,
          master_plugin_id: nil)

        master.valid?
        expect(master.errors[:master_plugin_id]).to include("can't be blank")
      end
    end

    describe "index" do
      it "should be invalid if blank" do
        master = build(:master,
          index: nil)

        master.valid?
        expect(master.errors[:index]).to include("can't be blank")
      end
    end


  end
end