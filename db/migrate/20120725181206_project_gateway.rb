class ProjectGateway < ActiveRecord::Migration
  def change
    remove_column :projects, :payment_gateway
    add_column :projects, :gateway_id, :integer
  end
end
