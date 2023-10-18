require 'rails_helper'

RSpec.describe TransactionCrop, type: :model do
  describe 'Associations' do
    it { should belong_to(:transaction_record).class_name('Transaction').with_foreign_key('transaction_id') }
    it { should belong_to(:crop) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:transaction_id) }
    it { should validate_presence_of(:crop_id) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
  end
end
