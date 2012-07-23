class CreateGatewayLogs < ActiveRecord::Migration
  def change
    create_table :gateway_logs do |t|
      t.integer :contribution_id
      t.integer :project_id
      t.datetime :called_at
      t.string :verb
      t.string :url
      t.string :params
      t.datetime :responded_at
      t.string :response
    end
  end
end
