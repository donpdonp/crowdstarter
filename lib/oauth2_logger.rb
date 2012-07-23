class Oauth2Logger
  def initialize(access_token)
    @access_token = access_token
  end

  def method_missing(name, *args, &block)
    # Log here
    @access_token.send(name, *args)
  end
end
