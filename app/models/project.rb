class Project < ActiveRecord::Base
  extend FriendlyId

  belongs_to :user
  has_many :contributions
  has_many :tags, :through => :taggings
  has_many :taggings
  friendly_id :name, :use => :slugged

  validates_presence_of :name, :funding_due, :amount, :user_id

  def collected
    contributions.succesful.sum(&:amount)
  end

  def remaining
    amount - collected
  end

  def percent_complete
    collected / amount
  end

  def disburse
    payment = FPS.pay( caller_reference:      "#{id}-payment",
                       charge_fee_to:         "Recipient",
                       marketplace_variable_fee: SETTINGS['aws']['fee_percentage'].to_s,
                       recipient_token_id:    user.aws_token,
                       sender_token_id:       contributions.successful.map(&:token).join(','),
                       transaction_amount:    amount.to_s )
  end
end
