class WepayAccountId < ActiveRecord::Migration
  def change
    add_column :users, :wepay_account_id, :string
#    add_column :users, :wepay_account_name, :string
  end
end
