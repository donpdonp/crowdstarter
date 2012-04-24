class FacebookUidString < ActiveRecord::Migration
  def up
    change_column :users, :facebook_uid, :string
  end

  def down
  end
end
