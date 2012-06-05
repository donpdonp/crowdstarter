class WepayTokens < ActiveRecord::Migration
  def change
    add_column :users, :wepay_token, :string
  end
end
