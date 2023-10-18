class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
         

    def send_on_create_confirmation_instructions
          # Don't send email here to prevent Devise from automatically sending the email.
     end
# def send_devise_notification(notification, *args)
#     devise_mailer.send(notification, self, *args).deliver_later
#   end

#   def devise_mailer
#     AdminMailer
#   end

end


