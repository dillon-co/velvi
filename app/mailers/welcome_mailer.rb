class WelcomeMailer < ApplicationMailer
  default from: 'dillon@velvi.io'

  def welcome_email(user)
    @user = user
    response = mail(to: user.email, subject: "Welcome, from the CEO.")
    response.deliver
  end
end
