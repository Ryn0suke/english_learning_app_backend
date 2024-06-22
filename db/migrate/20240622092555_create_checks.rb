class CreateChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :checks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :phrase, null: false, foreign_key: true
      t.boolean :state1, default: false
      t.boolean :state2, default: false
      t.boolean :state3, default: false

      t.timestamps
    end
  end
end
