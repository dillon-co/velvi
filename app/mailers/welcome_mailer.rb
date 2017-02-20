class WelcomeMailer < ApplicationMailer
  default from: 'dillon@velvi.io'

  def welcome_email(user)
    @user = User.find(user)
    puts "\n\nWelcome emailer working\n\n"
    response = mail(to: user.email, subject: "Welcome, from the CEO.")
  end
end
