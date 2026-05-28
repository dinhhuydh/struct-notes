class AddVersioningToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :parent_id, :bigint, null: true
    add_column :articles, :version_number, :integer, default: 1, null: false
    add_index :articles, :parent_id
    add_foreign_key :articles, :articles, column: :parent_id, on_delete: :nullify
  end
end
