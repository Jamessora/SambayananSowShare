require 'rails_helper'

RSpec.describe KycController, type: :controller do
    include Devise::Test::ControllerHelpers

    before :each do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        allow(controller).to receive(:authenticate_user!).and_return(true)
      end

      let(:user) { create(:user, kyc_status: kyc_status) }
      let(:kyc_status) {'pending'}
      before do
        # Simulate user authentication
        sign_in user
      end

    describe 'GET #new' do
    it 'should display the new KYC form' do
      # add your test code here
    end
    end

  describe 'POST #create' do
    context 'when the user is authenticated' do
      
      it 'submits KYC for approval' do
        kyc_params = attributes_for(:user, :with_kyc_pending)
        post :create, params: kyc_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end

      it 'fails to submit KYC' do
        post :create, params: { fullName: '' } # intentionally invalid
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['status']).to eq('error')
      end
    end
  end

  describe 'GET #edit' do
    it 'should display the edit KYC form' do
      # add your test code here
    end
  end

  describe 'PUT #update' do
    context 'when the user is authenticated' do
   
      it 'updates and resubmits KYC for approval' do
        kyc_params = attributes_for(:user, :with_kyc_approved)
        put :update, params: kyc_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end

      it 'fails to update KYC details' do
        put :update, params: { fullName: '' } # intentionally invalid
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['status']).to eq('error')
      end
    end
  end
end
