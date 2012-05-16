class Project < ActiveRecord::Base
  extend FriendlyId
  include Workflow

  belongs_to :user
  has_many :contributions
  has_many :tags, :through => :taggings
  has_many :taggings
  has_many :activities
  has_many :rewards
  friendly_id :name, :use => :slugged

  validates_presence_of :name, :funding_due, :amount, :user_id

  has_attached_file :image, :styles => {:thumb => "75x75>"},
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

  def collected
    contributions.authorizeds.sum(&:amount)
  end

  def remaining
    amount - collected
  end

  def percent_complete
    collected / amount
  end

  def end_of_project_processing
    if collected >= amount
      activities.create(:detail => "Final processing - Funded! Collecting contributions",
                        :code => "funded")
      fund!
    else
      activities.create(:detail => "Final processing - Insufficient contributions",
                        :code => "failed")
      fail!
    end
  end

  def fund
    contributions.authorizeds.each do |contrib|
      begin
        response = contrib.collect_payment_for(user)
        activities.create(:detail => "Collected #{contrib.user.email} $#{contrib.amount}",
                          :code => "collect",
                          :contribution => contrib)
        logger.info response.inspect
      rescue Boomerang::Errors::HTTPError => e
        activities.create(:detail => "Failed to collect from #{contrib.user.email} $#{contrib.amount}",
                          :code => "collect-fail",
                          :contribution => contrib)
        logger.error e.message
        logger.error e.http_response.body
      end
    end
  end

  def fail
    contributions.authorizeds.each do |contrib|
      response = contrib.cancel!
        activities.create(:detail => "Cancelled #{contrib.user.email} $#{contrib.amount}",
                          :code => "collect-cancel",
                          :contribution => contrib)
        logger.info response.inspect
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
end
