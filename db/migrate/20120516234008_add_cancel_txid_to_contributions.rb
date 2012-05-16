class AddCancelTxidToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :cancel_request_id, :string
  end
end
