class Transaction < ApplicationRecord
    has_many :transaction_crops, foreign_key: 'transaction_id'
    has_many :crops, through: :transaction_crops
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'

  validates :buyer_id, :seller_id, :status, presence: true

  # Numericality validations 
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Inclusion validations the possible statuses
  validates :status, inclusion: { in: ['Pending', 'For Seller Confirmation', 'For Buyer Payment', 'Payment Sent For Seller Confirmation', 'For Delivery', 'Completed', 'Cancelled'] }
end
