require 'spec_helper'

describe DashboardController do

  it "should display the explanation page" do
    subject.should_receive(:projects_tagged).with("frontpage", 10).and_return([])
    get :explain
    response.should render_template("dashboard/explain")
  end

end
