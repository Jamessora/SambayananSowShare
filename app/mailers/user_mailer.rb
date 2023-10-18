class UserMailer < ApplicationMailer
    default from: 'sambayanansowshare@gmail.com'

    def set_initial_password_email(user)
        @user = user
        @token = @user.initial_password_token
        mail(to: @user.email, subject: 'Set your initial password')
      end
end
