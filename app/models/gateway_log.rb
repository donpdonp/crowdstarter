class GatewayLog < ActiveRecord::Base
  belongs_to :project
  belongs_to :contribution
end
