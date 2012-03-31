class GithubController < ApplicationController
  def commit
    payload = JSON.parse(params["payload"])
    out = shell("restart.sh")
    render :nothing => true
  end

  private
  # easy to mock
  def shell(cmd)
    `/bin/sh #{cmd} &`
  end
end
