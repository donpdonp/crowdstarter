Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, SETTINGS['facebook']['key'], SETTINGS['facebook']['secret'], :display => 'popup'
end
