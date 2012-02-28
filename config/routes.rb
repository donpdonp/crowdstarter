Crowdstarter::Application.routes.draw do
  resources :projects do
    member do
      post :contribute
    end
    collection do
      get :count
    end
  end
  resources :users

  get "dashboard/explain"
  get "payment/tokenize"
  get "payment/clear"
  get "payment/receive"
  match "session" => "session#destroy", :via => :delete
  match "auth/:provider/callback" => "session#create"

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'dashboard#explain'

  # See how all your routes lay out with "rake routes"
end
