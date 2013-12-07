SETTINGS = Hashie::Mash.new(YAML.load(File.open(Rails.root+"config/settings.yml")))

# helper when building a route outside the scope of a controller
SETTINGS["default_url"].each do |k,v|
  Rails.application.routes.default_url_options[k.to_sym] = v
end