require 'spec_helper'

describe DashboardController do
  
  it "should display the explanation page" do
    get :explain
    response.should render_template("dashboard/explain")
  end

end
