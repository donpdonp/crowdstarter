class DashboardController < ApplicationController
  def landing
    @example_projects = projects_tagged("frontpage", 10)
  end

  def jobs
    @jobs = Delayed::Job.order("run_at desc").all
    @jobs.map! do |job|
      begin
        [job, job.payload_object.object]
      rescue Delayed::DeserializationError
        [job, nil]
      end
    end
    @jobs.sort!
  end

  def terms_of_service
  end

  private
  def projects_tagged(tag, limit)
    Tag.find_by_name(tag).projects.where(:workflow_state => 'fundable').
                                   order(:funding_due).limit(limit)
  end
end
