class WelcomeMailer < ApplicationMailer
  default from: 'dillon@velvi.io'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "Welcome, from the CEO.")
  end
end
