class ContributionsExtras < ActiveRecord::Migration
  def change
    add_column :contributions, :reference, :string
    add_column :contributions, :expiry, :string
    add_column :contributions, :token, :string
    add_column :contributions, :status, :string
  end
end
