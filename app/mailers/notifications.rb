class Notifications < ActionMailer::Base
  default from: "from@example.com"

  def thanks(contrib)
    @greeting = "Hi #{contrib.user.username},"
    @to = contrib.user.email
    @subject = "Thanks for your donation!"
    @project = contrib.project.name
    @donation = contrib.amount

    mail to: @to, subject: @subject, greeting: @greeting,
         project: @project, donation: @donation
  end
end
