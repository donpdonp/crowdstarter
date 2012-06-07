class Reward < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :amount, :description, :presence => true
end
