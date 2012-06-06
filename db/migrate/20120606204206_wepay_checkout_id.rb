class WepayCheckoutId < ActiveRecord::Migration
  def change
    add_column :contributions, :wepay_checkout_id, :string
  end
end
