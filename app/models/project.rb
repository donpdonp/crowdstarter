class Project < ActiveRecord::Base
  belongs_to :user
  has_many :contributions

  validates_presence_of :name, :funding_due, :amount, :user_id

  def collected
    contributions.select{|c| c.status == "SC"}.sum(&:amount)
  end

  def percent_complete
    collected / amount
  end
end
