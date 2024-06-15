class AddUniqueIndexToTagUserRelations < ActiveRecord::Migration[7.0]
  def change
    add_index :tag_user_relations, [:user_id, :tag_id], unique: true
  end
end
