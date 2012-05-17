class Notifications < ActionMailer::Base
  default from: "robot@everythingfunded.com"

  def contribution_thanks(contrib)
    @user = contrib.user
    @to = @user.email
    @project = contrib.project
    @subject = "Contribution: {@project.name}"
    @contribution = contrib

    mail to: @to, subject: @subject
  end

  def project_failed(project)
    subject = "Project closed: #{project.name}"
    @project = project

    mail to: project.user.email, subject: subject
  end
end
