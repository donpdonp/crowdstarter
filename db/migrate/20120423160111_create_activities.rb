class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :contribution_id
      t.integer :project_id
      t.integer :user_id
      t.string :code
      t.text :detail

      t.timestamps
    end
  end
end
