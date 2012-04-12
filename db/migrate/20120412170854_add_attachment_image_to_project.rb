class AddAttachmentImageToProject < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.has_attached_file :image
    end
  end

  def self.down
    drop_attached_file :projects, :image
  end
end
