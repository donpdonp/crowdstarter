class RewardedContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :reward_id, :integer
  end
end
