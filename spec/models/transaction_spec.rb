require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'Associations' do
    it { should have_many(:transaction_crops) }
    it { should have_many(:crops).through(:transaction_crops) }
    it { should belong_to(:buyer).class_name('User') }
    it { should belong_to(:seller).class_name('User') }
  end

  describe 'Validations' do
    it { should validate_presence_of(:buyer_id) }
    it { should validate_presence_of(:seller_id) }
    it { should validate_presence_of(:status) }
    it { should validate_numericality_of(:total_price).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_inclusion_of(:status).in_array(['Pending', 'Completed', 'Cancel']) }
  end
end
