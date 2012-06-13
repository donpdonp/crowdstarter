Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, SETTINGS.facebook.app_id, SETTINGS.facebook.secret
end
