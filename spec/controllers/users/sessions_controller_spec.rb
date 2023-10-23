require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

     before :each do
        @request.env["devise.mapping"] = Devise.mappings[:user]
    end

  describe 'POST #create' do
    let(:user) { create(:user) }

    context 'with valid credentials' do
      it 'returns success: true in JSON response' do
        post :create, params: { email: user.email, password: user.password }
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end

    context 'with invalid credentials' do
      it 'returns success: false in JSON response' do
        post :create, params: { email: user.email, password: 'wrongpassword' }
        expect(JSON.parse(response.body)['success']).to eq(false)
      end
    end
  end

  # describe 'DELETE #destroy' do
  #   let(:user) { create(:user) }
  #   let(:token) { user.generate_jwt }
  
  #   it 'logs out the user' do
  #     # Adding the Authorization header
  #     request.headers['Authorization'] = "Bearer #{token}"
  
  #     delete :destroy
  #     expect(JwtDenylist.where(jti: decoded_jwt['jti']).exists?).to be_truthy
      
  #     expect(response).to have_http_status(:success)
      
  #   end
  # end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }
    let(:token) { user.generate_jwt }
  
    before do
      # Simulate user login before testing logout
      sign_in user
    end
  
    it 'logs out the user' do
      request.headers['Authorization'] = "Bearer #{token}"
  
      delete :destroy
  
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' }).first
      expect(JwtDenylist.where(jti: decoded_token['jti']).exists?).to be_truthy
      expect(subject.current_user).to be_nil
      
    end
  
    it 'returns a successful logout message' do
      request.headers['Authorization'] = "Bearer #{token}"
  
      delete :destroy
  
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["message"]).to eq('You have logged out successfully.')
    end
  
    it 'has a status of :ok' do
      request.headers['Authorization'] = "Bearer #{token}"
  
      delete :destroy
  
      expect(response).to have_http_status(:ok)
    end
  end
  
end
