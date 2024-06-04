class CreatePhrases < ActiveRecord::Migration[7.0]
  def change
    create_table :phrases do |t|
      t.text :japanese
      t.text :english
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :phrases, [:user_id, :created_at]
  end
end
