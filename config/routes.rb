Crowdstarter::Application.routes.draw do
  get "dashboard/explain"
  get "dashboard/contact_us"
  get "dashboard/jobs"
  get "payment/tokenize"
  get "payment/clear"
  get "payment/receive"
  post "github/commit"
  match "session" => "session#destroy", :via => :delete
  match "auth/:provider/callback" => "session#create"

  resources :projects do
    member do
      post :contribute
    end
    collection do
      get :count
    end
  end
  resources :users

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'dashboard#explain'

  # See how all your routes lay out with "rake routes"
end
