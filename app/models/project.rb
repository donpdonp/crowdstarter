class Project < ActiveRecord::Base
  extend FriendlyId

  belongs_to :user
  has_many :contributions
  has_many :tags, :through => :taggings
  has_many :taggings
  friendly_id :name, :use => :slugged

  validates_presence_of :name, :funding_due, :amount, :user_id

  def collected
    contributions.select{|c| c.status == "SC"}.sum(&:amount)
  end

  def remaining
    amount - collected
  end

  def percent_complete
    collected / amount
  end
end
