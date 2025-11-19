class CreateSources < ActiveRecord::Migration[8.1]
  def change
    create_table :sources do |t|
      t.string :platform, null: false
      t.string :username, null: false

      t.timestamps
    end

    add_index :sources, [ :platform, :username ], unique: true
  end
end
