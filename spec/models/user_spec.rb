require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Associations' do
    it { should have_many(:crops) }
    it { should have_many(:bought_transactions) }
    it { should have_many(:sold_transactions) }
    it { should have_one_attached(:idPhoto) }
  end

  describe 'Validations' do
    # Existing validations
    it { should validate_presence_of(:fullName).on(:create) }
    it { should validate_presence_of(:birthday).on(:create) }
    it { should validate_presence_of(:address_country).on(:create) }
    it { should validate_presence_of(:address_city).on(:create) }
    it { should validate_presence_of(:address_baranggay).on(:create) }
    it { should validate_presence_of(:address_street).on(:create) }
    it { should validate_presence_of(:idType).on(:create) }
    it { should validate_presence_of(:idNumber).on(:create) }

    # Test for acceptable_image method
  #   context 'when image is attached' do
  #     let(:user) { build(:user, idPhoto: fixture_file_upload('spec/fixtures/files/sample.jpg', 'image/jpeg')) }

  #     it 'is valid' do
  #       expect(user).to be_valid
  #     end
  #   end

  #   context 'when image is too large' do
  #     let(:user) { build(:user, idPhoto: fixture_file_upload('spec/fixtures/files/large_image.jpg', 'image/jpeg')) }

  #     it 'is not valid' do
  #       expect(user).not_to be_valid
  #     end
  #   end
   end

  describe '#kyc_required?' do
    # Existing tests
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

    context 'when skip_kyc_validation is true' do
      let(:user) { build(:user, kyc_status: 'pending', skip_kyc_validation: true) }

      it 'returns false' do
        expect(user.kyc_required?).to be(false)
      end
    end
  end

  # describe '#from_omniauth' do
  #   let(:auth_hash) { OmniAuth::AuthHash.new(provider: 'google_oauth2', uid: '1234', info: { email: 'test@example.com' }) }

  #   it 'creates a new user if one does not exist' do
  #     expect { User.from_omniauth(auth_hash) }.to change { User.count }.by(1)
  #   end

  #   it 'finds an existing user if one exists' do
  #     existing_user = User.from_omniauth(auth_hash)
  #     expect(User.from_omniauth(auth_hash)).to eq(existing_user)
  #   end
  # end
end
