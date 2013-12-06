class AddWepayPreapprovalIdToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :wepay_preapproval_id, :string
  end
end
