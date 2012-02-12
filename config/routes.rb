Crowdstarter::Application.routes.draw do
  get "dashboard/explain"

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'dashboard#explain'

  # See how all your routes lay out with "rake routes"
end
