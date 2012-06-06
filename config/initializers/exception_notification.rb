unless Rails.env.development?
  config.middleware.use ::ExceptionNotifier,
    :email_prefix => "",
    :sender_address => SETTINGS["exception_notifier"]["from"],
    :exception_recipients => SETTINGS["exception_notifier"]["recipients"]
end