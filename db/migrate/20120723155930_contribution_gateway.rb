class ContributionGateway < ActiveRecord::Migration
  def change
    add_column :contributions, :gateway_id, :integer
  end
end
