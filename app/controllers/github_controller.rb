class GithubController < ApplicationController
  def commit
    payload = JSON.parse(params["payload"])
    logger.info("github params: #{payload}")
    out = shell("restart.sh")
    logger.info("github pull output: #{out}")
    render :nothing => true
  end
end
