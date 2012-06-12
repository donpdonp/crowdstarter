require 'spec_helper'

describe PaymentController do

  it "should process an Amazon payment notification" do
    params = {"signature"=>"r4mc8LVObGwlnDykuMAb0TM=",
              "expiry"=>"09/2017",
              "signatureVersion"=>"2",
              "signatureMethod"=>"RSA-SHA1",
              "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzjnntz6x3askklwwlu3pd6u8akh85aanupa2tx1jt1k8c9v02",
              "tokenID"=>"6J5FGQ",
              "status"=>"SC",
              "callerReference"=>"proj:8-fbid:692421751-time:1334266878"}

    project = mock_model(Project)
    user = mock_model(User)
    contribution = mock_model(Contribution, {:project => project,
                                             :user => user})
    contribution.should_receive(:receive_payment)
    contribution.should_receive(:incomplete?).and_return(true)
    contribution.should_receive(:authorized?).and_return(true)
    Contribution.should_receive(:find_by_reference).with(params["callerReference"]).and_return(contribution)
    get :receive, params
    response.should redirect_to(project_path(project))
  end
end
