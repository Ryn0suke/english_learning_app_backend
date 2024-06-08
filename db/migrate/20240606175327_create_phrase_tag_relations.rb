class CreatePhraseTagRelations < ActiveRecord::Migration[7.0]
  def change
    create_table :phrase_tag_relations do |t|
      t.references :phrase, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
