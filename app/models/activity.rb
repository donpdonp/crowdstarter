class Activity < ActiveRecord::Base
  belongs_to :contribution
  belongs_to :project
  belongs_to :user

end
