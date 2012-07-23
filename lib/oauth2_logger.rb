class Oauth2Logger
  def initialize(access_token, contribution)
    @access_token = access_token
    @contribution = contribution
  end

  def method_missing(name, *args, &block)
    log = GatewayLog.create(:called_at => Time.now,
                          :project => @contribution.project,
                          :contribution => @contribution,
                          :verb => name,
                          :url => args.first,
                          :params => args.last[:params].to_json)
    response = @access_token.send(name, *args)
    response_params = response.parsed
    log.response = response_params.to_json
    log.responded_at = Time.now
    log.save
    response_params
  end
end
