class Tag < ActiveRecord::Base
  has_many :projects, :through => :taggings
  has_many :taggings

  validates :name, :uniqueness => true
end
