class AddToneToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :tone, :string, default: "magazine_editorial", null: false
  end
end
