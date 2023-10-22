class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :crops
  has_many :bought_transactions, foreign_key: :buyer_id, class_name: 'Transaction'
  has_many :sold_transactions, foreign_key: :seller_id, class_name: 'Transaction'
  has_one_attached :idPhoto
  validate :acceptable_image, if: :kyc_required?
  #validates :password, presence: true, unless: -> { provider.present? }
  # validate :password_presence
  
  enum kyc_status: { unsubmitted: 'nil', pending: 'pending', approved: 'approved', rejected: 'rejected' }
  attr_accessor :skip_kyc_validation
  validates :fullName, :birthday, :idType, :idNumber, presence: true, if: :kyc_required?
 
  validates :address_country, presence: true, if: :kyc_required?
  validates :address_city, presence: true, if: :kyc_required?
  validates :address_baranggay, presence: true, if: :kyc_required?
  validates :address_street, presence: true, if: :kyc_required?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :jwt_authenticatable, omniauth_providers: [:google_oauth2], jwt_revocation_strategy: JwtDenylist
          

  # def self.from_omniauth(auth, send_email: false)
  #  user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #     user.email = auth.info.email
  #     user.google_id = auth.extra.id_info.sub
  #     user.password = Devise.friendly_token[0, 20]
  #     user.last_name = auth.info.last_name
  #     user.first_name = auth.info.first_name
  #     user.avatar_url = auth.info.image
  #     #user.has_password = false
  #     end.tap do |user|
  #       Rails.logger.debug "User: #{user.inspect}"
        
  #   end
  #   if user.new_record? 
  #     if user.save
  #       user.generate_initial_password_token!
  #       UserMailer.set_initial_password_email(user).deliver_now if send_email
  #       Rails.logger.debug "User saved: #{user.errors.full_messages}"
        
  #         else
  #         Rails.logger.debug "User not saved: #{user.errors.full_messages}"
  #       end
  #     end
  
  #   user.tap do |u|
  #     Rails.logger.debug "User: #{u.inspect}"
  #   end
  # end

  # Inside User model
def self.from_omniauth(auth, send_email: false)
  user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    user.email = auth.info.email
    user.google_id = auth.extra.id_info.sub
    user.password = Devise.friendly_token[0, 20]
    user.last_name = auth.info.last_name
    user.first_name = auth.info.first_name
    user.avatar_url = auth.info.image
    user.has_password = false # set the flag here
    user.skip_kyc_validation = true
  end

  if user.new_record?
    if user.valid?
      user.save!
      user.generate_initial_password_token!
      UserMailer.set_initial_password_email(user).deliver_now if send_email
      Rails.logger.debug "User saved: #{user.errors.full_messages}"
    else
      Rails.logger.debug "User not saved: #{user.errors.full_messages.join(', ')}"
    end
  end


  user
end

def kyc_required?
  return false if skip_kyc_validation
  kyc_status != 'approved'
end
    
  def generate_secure_token
    SecureRandom.urlsafe_base64
  end

  def generate_jwt
    JWT.encode({ id: id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
  end

  # def generate_initial_password_token!
  #   self.initial_password_token = generate_secure_token
  #   self.initial_password_sent_at = Time.now.utc
  #   save!
  # end

  def generate_initial_password_token!
    update(
      initial_password_token: generate_secure_token,
      initial_password_token_sent_at: Time.now.utc
    )
  end
  
  def generate_password_token!
    self.reset_password_token = generate_secure_token
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def acceptable_image
    return unless idPhoto.attached?

    unless idPhoto.blob.byte_size <= 1.megabyte
      errors.add(:idPhoto, "is too big")
    end

    acceptable_types = ["image/jpeg", "image/png"]
    unless acceptable_types.include?(idPhoto.blob.content_type)
      errors.add(:idPhoto, "must be a JPEG or PNG")
    end
  end
  
  def password_presence
    if new_record? || changes.include?(:password)
      errors.add(:password, "can't be blank") if password.blank?
    end
  end
    
end
