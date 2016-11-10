class AddBlacklistedAuthorsTable < ActiveRecord::Migration
  def change
    create_table :blacklisted_authors do |t|
      t.string :source, limit: 32, null: false
      t.string :author, limit: 64, null: false
    end

    add_index :blacklisted_authors, :source
    add_index :blacklisted_authors, :author

    nexus_blacklist = ["TheVampireDante", "Arthmoor", "Shurah", "Jokerine",
        "Shezrie", "Faelrin", "Mac2636", "Yourenotsupposedtobeinhere"]
    nexus_blacklist.each do |username|
      BlacklistedAuthor.create(source: "NexusInfo", author: username)
    end
  end
end
