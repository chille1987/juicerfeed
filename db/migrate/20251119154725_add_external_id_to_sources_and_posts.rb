class AddExternalIdToSourcesAndPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :sources, :external_id, :integer
    add_index  :sources, :external_id, unique: true

    add_column :posts, :external_id, :integer
    add_index  :posts, :external_id, unique: true
  end
end
