require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:fullName).on(:create) }
    it { should validate_presence_of(:birthday).on(:create) }
    it { should validate_presence_of(:address_country).on(:create) }
    it { should validate_presence_of(:address_city).on(:create) }
    it { should validate_presence_of(:address_baranggay).on(:create) }
    it { should validate_presence_of(:address_street).on(:create) }
    it { should validate_presence_of(:idType).on(:create) }
    it { should validate_presence_of(:idNumber).on(:create) }
  end

  describe '#kyc_required?' do
    context 'when kyc_status is approved' do
      let(:user) { build(:user, kyc_status: 'approved') }

      it 'returns false' do
        expect(user.kyc_required?).to be(false)
      end
    end

    context 'when kyc_status is not approved' do
      let(:user) { build(:user, kyc_status: 'pending') }

      it 'returns true' do
        expect(user.kyc_required?).to be(true)
      end
    end
  end
end
