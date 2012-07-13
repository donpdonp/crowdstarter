WEPAY = OAuth2::Client.new(SETTINGS.payment_gateways.wepay.client.id,
                           SETTINGS.payment_gateways.wepay.client.secret,
                                 {:site => SETTINGS.payment_gateways.wepay.sandbox ?
                                    "https://stage.wepayapi.com/" : "https://wepayapi.com/",
                                  :authorize_url => SETTINGS.payment_gateways.wepay.sandbox ?
                                    "https://stage.wepay.com/v2/oauth2/authorize" : "https://www.wepay.com/v2/oauth2/authorize",
                                  :token_url => "/v2/oauth2/token",
                                  :connection_opts => {
                                    :ssl => {:verify=> !Rails.env.development?}
                                    }})
