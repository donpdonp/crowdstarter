class Gateway < ActiveRecord::Base
  validates :provider, :uniqueness => true

  after_find :gateway_setup

  attr_reader :client

  def gateway_setup
    wepay_setup if provider == "wepay"
  end

  def wepay_setup
    @client = OAuth2::Client.new(access_key, access_secret,
                                 {:site => sandbox ?
                                    "https://stage.wepayapi.com/" :
                                    "https://wepayapi.com/",
                                  :authorize_url => sandbox ?
                                    "https://stage.wepay.com/v2/oauth2/authorize" :
                                    "https://www.wepay.com/v2/oauth2/authorize",
                                  :token_url => "/v2/oauth2/token",
                                  :connection_opts => {
                                    :ssl => {:verify=> !Rails.env.development?}
                                    },
                                  :raise_errors => false})
  end

end
