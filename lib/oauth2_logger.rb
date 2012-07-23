class Oauth2Logger
  def initialize(gateway_client, user, contribution)
    @access_token = OAuth2::AccessToken.from_hash(
                                       gateway_client,
                                       user.wepay_token_hash)
    @user = user
    @contribution = contribution
  end

  def method_missing(name, *args, &block)
    log = GatewayLog.create(:called_at => Time.now,
                            :user => @user,
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
