class AddWorkflow < ActiveRecord::Migration
  def change
    add_column :projects, :workflow_state, :string
    add_column :contributions, :workflow_state, :string
  end
end
