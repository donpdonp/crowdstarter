class CreateGatewayLogs < ActiveRecord::Migration
  def change
    create_table :gateway_logs do |t|
      t.integer :contribution_id
      t.integer :user_id
      t.integer :project_id
      t.datetime :called_at
      t.string :verb
      t.text :url
      t.text :params
      t.datetime :responded_at
      t.text :response
    end
  end
end
