class AddPlanToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :plan, :string, default: "free", null: false
    add_column :users, :generation_count_reset_at, :datetime

    # Update existing users: set generation_limit to 5 (free tier default)
    reversible do |dir|
      dir.up do
        execute "UPDATE users SET generation_limit = 5 WHERE generation_limit = 20"
        execute "UPDATE users SET generation_count_reset_at = NOW()"
      end
    end
  end
end
