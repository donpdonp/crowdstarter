class Project < ActiveRecord::Base
  extend FriendlyId

  belongs_to :user
  has_many :contributions
  has_many :tags, :through => :taggings
  has_many :taggings
  friendly_id :name, :use => :slugged

  validates_presence_of :name, :funding_due, :amount, :user_id

  def collected
    contributions.successful.sum(&:amount)
  end

  def remaining
    amount - collected
  end

  def percent_complete
    collected / amount
  end

  def disburse
    contributions.successful.map(&:token).each do |sender_token|
      payment = FPS.pay( caller_reference:      "#{id}-#{rand(100)}",
                         recipient_token_id:    user.aws_token,
                         sender_token_id:       sender_token,
                         transaction_amount:    amount.to_s )
    end
  end
end
