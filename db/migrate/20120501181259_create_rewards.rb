class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.integer :project_id
      t.string :name
      t.string :description
      t.decimal :amount 

      t.timestamps
    end
  end
end
