amazon_gateway = Gateway.where(:provider=>'amazon').first
if amazon_gateway
  FPS = Boomerang.new( amazon_gateway.access_key,
                       amazon_gateway.access_secret,
                       amazon_gateway.sandbox)  # use sandbox (false sends to production)
end