class Reward < ActiveRecord::Base
  belongs_to :project

  # attr_accessible :amount, :description
  validates :amount, :description, :presence => true
  validates :amount, :uniqueness => { :scope => :project_id,
                                      :message => "is in use by another reward." }

  html_fragment :description, :scrub => :escape
end
