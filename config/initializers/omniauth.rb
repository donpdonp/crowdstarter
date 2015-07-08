Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, SETTINGS.facebook.app_id, SETTINGS.facebook.secret,
           :callback_url => "https://#{SETTINGS["hostname"]}/auth/facebook/callback"
end

if Rails.env.production?
  module OmniAuth
    module Strategy
      def full_host
        uri = URI.parse(request.url)
        uri.path = ''
        uri.query = nil
        uri.port = (uri.scheme == 'https' ? 443 : 80)
        uri.to_s
      end
    end
  end
end
