require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
    include Devise::Test::ControllerHelpers

    before :each do
       @request.env["devise.mapping"] = Devise.mappings[:user]
   end
   
  describe 'POST #create' do
    context 'when valid id_token is provided' do
      it 'creates a new user' do
        post :create, params: { id_token: 'valid_token' }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when invalid id_token is provided' do
      it 'returns an error' do
        post :create, params: { id_token: 'invalid_token' }
        expect(JSON.parse(response.body)['success']).to eq(false)
      end
    end
  end
end
