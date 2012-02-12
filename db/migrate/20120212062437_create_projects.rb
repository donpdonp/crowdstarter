class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.datetime :funding_due
      t.decimal :amount
      t.integer :user_id

      t.timestamps
    end
  end
end
