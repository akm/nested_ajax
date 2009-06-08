ActiveRecord::Schema.define(:version => nil) do

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "blog"
    t.string   "twitter"
    t.string   "google_account"
    t.string   "github_account"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_memberships", :force => true do |t|
    t.integer  "product_id"
    t.integer  "person_id" 
    t.string   "role_cd", :limit => 2
    t.date     "joined_on"
    t.date     "leaved_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "type_cd", :limit => 2
    t.string   "site_url"
    t.string   "repogitory_url"
    t.text     "descriptions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
