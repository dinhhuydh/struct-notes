class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :hook
      t.json :body_sections
      t.text :best_for
      t.text :not_for
      t.text :ethics_notes
      t.json :key_facts
      t.text :raw_notes
      t.string :status, default: "draft", null: false
      t.references :user, null: false, foreign_key: true
      t.references :template, null: true, foreign_key: true

      t.timestamps
    end
  end
end
