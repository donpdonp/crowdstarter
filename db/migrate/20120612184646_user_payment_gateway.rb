class UserPaymentGateway < ActiveRecord::Migration
  def change
    add_column :users, :payment_gateway, :string
    add_column :projects, :payment_gateway, :string
    add_column :contributions, :type, :string
  end
end
