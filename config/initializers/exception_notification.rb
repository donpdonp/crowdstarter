Crowdstarter::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "",
  :sender_address => %{"notifier" },
  :exception_recipients => SETTINGS["exception_notifier"]["recpipents"]
