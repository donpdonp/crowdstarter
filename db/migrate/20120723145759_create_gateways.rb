class CreateGateways < ActiveRecord::Migration
  def change
    create_table :gateways do |t|
      t.string :provider
      t.string :access_key
      t.string :access_secret
      t.boolean :sandbox

      t.timestamps
    end
  end
end
