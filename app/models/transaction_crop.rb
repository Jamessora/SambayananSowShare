class TransactionCrop < ApplicationRecord
  belongs_to :transaction_record, class_name: 'Transaction', foreign_key: 'transaction_id'
  belongs_to :crop

  validates :transaction_id, presence: true
  validates :crop_id, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  
end
