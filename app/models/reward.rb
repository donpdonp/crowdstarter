class Reward < ActiveRecord::Base
  # attr_accessible :amount, :description
  validates :amount, :description, :presence => true

  html_fragment :description, :scrub => :escape
end
