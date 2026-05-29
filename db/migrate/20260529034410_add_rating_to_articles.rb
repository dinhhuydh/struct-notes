class AddRatingToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :rating, :string
  end
end
