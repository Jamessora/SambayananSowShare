class Crop < ApplicationRecord
    has_many :transaction_crops
    has_many :transactions, through: :transaction_crops
    belongs_to :user

    validates :crop_name, presence: true
    validates :crop_price, presence: true, numericality: { greater_than: 0 }
    validates :crop_status, presence: true,  inclusion: { in: ['available', 'unavailable', 'expired'] }
    validates :crop_expiry_date, presence: true
    validates :crop_quantity, presence: true, numericality: { only_integer: true}
end
