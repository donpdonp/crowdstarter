class Project < ActiveRecord::Base
  extend FriendlyId
  include Workflow

  belongs_to :user
  belongs_to :gateway
  has_many :contributions
  has_many :tags, :through => :taggings
  has_many :taggings
  has_many :activities
  has_many :rewards
  has_many :gateway_logs

  friendly_id :name, :use => :slugged

  validates :name, :funding_due, :amount, :user_id, :gateway_id, :presence => true

  has_attached_file :image, :styles => {:thumb => "133x75>",
                                        :medium => "530x300>"},
              :default_url => "/assets/:style/missing.png"


  scope :fundables, where(:workflow_state => :fundable)

  html_fragment :description, :scrub => :escape

  workflow do
    state :editable do
      event :publish, :transitions_to => :fundable
    end
    state :fundable do
      event :fund, :transitions_to => :funded
      event :fail, :transitions_to => :failed
      event :unpublish, :transitions_to => :editable
    end
    state :funded do
      event :disburse, :transitions_to => :disbursed
    end
    state :failed
    state :disbursed
  end

  def contributed_amount
    contributions.reserveds.sum(&:amount)
  end

  def collected_amount
    contributions.captureds.sum(&:amount)
  end

  def cancelled_amount
    contributions.cancelleds.sum(&:amount)
  end

  def remaining
    amount - collected_amount
  end

  def percent_complete
    if funded?
      collected_amount / amount
    else
      contributed_amount / amount
    end
  end

  def end_of_project_processing
    if fundable?
      if contributed_amount + collected_amount >= amount
        activities.create(:detail => "Final processing - Funded! Collecting contributions",
                          :code => "funded")
        fund!
        Notifications.delay(:queue => 'mailer').project_funded(self)
      else
        activities.create(:detail => "Final processing - Insufficient contributions",
                          :code => "failed")
        fail!
        Notifications.delay(:queue => 'mailer').project_failed(self)
      end
    end
  end

  def gateway_sync
    contributions.each{|c| c.wepay_sync}
  end

  def fund
    contributions.reserveds.each do |contrib|
      # Kick off the capture and wait for the IPN
      # contrib.wepay_refresh
      contrib.wepay_capture
    end
  end

  def fail
    contributions.authorizeds.each do |contrib|
      response = contrib.wepay_cancel
      logger.info response.inspect
      if contrib.cancelled?
        activities.create(:detail => "Cancelled #{contrib.user.email} $#{contrib.amount}",
                          :code => "collect-cancel",
                          :contribution => contrib)
        Notifications.delay(:queue => 'mailer').contribution_cancelled(contrib)
      else
        activities.create(:detail => "Failed to cancel from #{contrib.user.email} $#{contrib.amount}",
                          :code => "collect-cancel-fail",
                          :contribution => contrib)
        logger.error e.message
        logger.error e.http_response.body
      end
    end
  end

  def publish
    if rewards.empty?
      halt! "Define at least one reward before publishing."
    end
  end

  def unpublish
    # kill delayed job(s)
    self.jobs.each{|job| job.destroy}
  end

  def jobs
    Delayed::Job.all.select do |job|
      begin
        job.payload_object.object == self
      rescue Delayed::DeserializationError
        # skip this one
      end
    end
  end

  def closest_reward(amount)
    rewards.order("amount asc").select{|r| amount >= r.amount}.last
  end

  def smallest_reward
    rewards.order("amount asc").first
  end
end
