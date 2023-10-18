# app/services/user_service.rb
class UserService
    def self.from_omniauth_and_send_email(auth)
      user = User.from_omniauth(auth)
      user.generate_initial_password_token!
      UserMailer.set_initial_password_email(user).deliver_now
      user
    end
  end
  