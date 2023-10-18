class Admin::KycController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :authenticate_admin!
  
  def index
    users_with_pending_kyc = User.where(kyc_status: 'pending').with_attached_idPhoto
    response_data = users_with_pending_kyc.map do |user|
      user_data = {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        birthday: user.birthday,
        address_country: user.address_country,
        address_city: user.address_city,
        address_baranggay: user.address_baranggay,
        address_street: user.address_street,
        idType: user.idType,
        idNumber: user.idNumber,
        kyc_status: user.kyc_status
      }
      
      user_data[:idPhoto] = url_for(user.idPhoto) if user.idPhoto.attached?
      
      user_data  # Make sure to return the user_data hash from the block
    end
  
    render json: response_data
  end

  
  
  
  def approve
    user = User.find(params[:id])
    user.update(kyc_status: 'approved')
    # Send email notification
    KycMailer.kyc_approved_email(user).deliver_now
    render json: { message: 'KYC approved successfully.' }, status: :ok
  end
  
  def reject
    user = User.find(params[:id])
    user.update(kyc_status: 'rejected')
    render json: { message: 'KYC rejected.' }, status: :ok
  end
end
