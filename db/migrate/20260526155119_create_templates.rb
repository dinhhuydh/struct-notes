class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.text :prompt_template
      t.json :schema
      t.boolean :is_default, default: false, null: false
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end

    add_index :templates, :slug, unique: true
  end
end
