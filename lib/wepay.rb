module Wepay
  def wepay_api
    Oauth2Logger.new(OAuth2::AccessToken.from_hash(
                                       gateway.client,
                                       project.user.wepay_token_hash),
                     self)
  end

  def wepay_status
    wp_params = {:checkout_id => wepay_checkout_id}
    logger.info "/v2/checkout/ #{wp_params.inspect}"
    respone = wepay_api.get("/v2/checkout",
                   :params => wp_params)
    response = project.user.wepay.get("/v2/checkout",
                   :params => wp_params).parsed
    logger.info response.inspect
    response
  end
end
