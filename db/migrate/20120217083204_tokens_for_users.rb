class TokensForUsers < ActiveRecord::Migration
  def change
    add_column :users, :aws_token, :string
    add_column :users, :aws_token_refund, :string
  end
end
