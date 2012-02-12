class AddFacebookUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_uid, :integer
  end
end
