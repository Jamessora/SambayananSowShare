require 'rails_helper'

RSpec.describe Admin, type: :model do
  let(:admin) { build(:admin) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(admin).to be_valid
    end

    it 'is not valid without an email' do
      admin.email = nil
      expect(admin).to_not be_valid
    end

    it 'is not valid without a password' do
      admin.password = nil
      expect(admin).to_not be_valid
    end
  end

  describe 'Devise modules' do
    it 'should include :database_authenticatable' do
      expect(Admin.ancestors.include?(Devise::Models::DatabaseAuthenticatable)).to be_truthy
    end

    it 'should include :registerable' do
      expect(Admin.ancestors.include?(Devise::Models::Registerable)).to be_truthy
    end

    it 'should include :recoverable' do
      expect(Admin.ancestors.include?(Devise::Models::Recoverable)).to be_truthy
    end

    it 'should include :rememberable' do
      expect(Admin.ancestors.include?(Devise::Models::Rememberable)).to be_truthy
    end

    it 'should include :validatable' do
      expect(Admin.ancestors.include?(Devise::Models::Validatable)).to be_truthy
    end

    it 'should include :confirmable' do
      expect(Admin.ancestors.include?(Devise::Models::Confirmable)).to be_truthy
    end
  end
end
