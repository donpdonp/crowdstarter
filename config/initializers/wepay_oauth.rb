WEPAY = OAuth2::Client.new(SETTINGS['wepay']['client']['id'],
                           SETTINGS['wepay']['client']['secret'],
                                 {:site => "https://stage.wepay.com/",
                                  :authorize_url => "/v2/oauth2/authorize"})
