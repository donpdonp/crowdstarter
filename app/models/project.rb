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
    contributions.successful.each do |contrib|
      begin
        payment = FPS.pay( caller_reference:      "#{id}-#{rand(100)}",
                           marketplace_variable_fee: SETTINGS['aws']['fee_percentage'].to_s,
                           recipient_token_id:    user.aws_token,
                           sender_token_id:       contrib.token,
                           transaction_amount:    contrib.amount.to_s )
      rescue Boomerang::Errors::HTTPError => e
        puts e.inspect
        puts e.http_response.body
      end
    end
  end
end
