class KycMailer < ApplicationMailer
    default from: 'sambayanansowshare@gmail.com'
  
    def kyc_approved_email(user)
      @user = user
      mail(to: @user.email, subject: 'KYC Approved')
    end
end