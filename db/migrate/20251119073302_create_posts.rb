class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :source, null: false, foreign_key: true
      t.integer :comments, null: false, default: 0
      t.text :content
      t.string :hashtags
      t.boolean :is_promoted, null: false, default: false
      t.integer :likes, null: false, default: 0
      t.string :location
      t.string :media_type
      t.string :media_url
      t.string :mentions
      t.string :profile_image
      t.integer :shares, null: false, default: 0
      t.integer :views, null: false, default: 0

      t.timestamps
    end

    add_index :posts, [ :source_id, :created_at ], name: "index_posts_on_source_and_created_at"
    add_index :posts, [ :media_type, :created_at ], name: "index_posts_on_media_type_and_created_at"
    add_index :posts, :views, name: "index_posts_on_views_desc"
    add_index :posts, [ :media_type, :views ], name: "index_posts_on_media_type_and_views"
  end
end
