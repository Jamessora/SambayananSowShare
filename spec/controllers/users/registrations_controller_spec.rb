require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
    include Devise::Test::ControllerHelpers

    before :each do
       @request.env["devise.mapping"] = Devise.mappings[:user]
   end
   
   describe 'POST #create' do
    let(:valid_attributes) do
      {
        id_token: 'some_valid_google_token'
      }
    end

    let(:invalid_attributes) do
      {
        id_token: 'some_invalid_google_token'
      }
    end

    before do
      # You might need to stub methods that interact with Google's API
      allow_any_instance_of(GoogleIDToken::Validator).to receive(:check).and_return({
        'sub' => '123',
        'email' => 'test@example.com',
        # ... other fields
      })
    end

    context 'with valid params' do
      it 'creates a new User' do
        post :create, params: { id_token: valid_attributes[:id_token] }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end

    context 'with invalid params' do
      it 'does not create a new User' do
        allow_any_instance_of(GoogleIDToken::Validator).to receive(:check).and_raise(GoogleIDToken::ValidationError.new('Invalid token'))
        post :create, params: { id_token: invalid_attributes[:id_token] }
        expect(response).to have_http_status(:ok) # Or whatever status code you are returning
        expect(JSON.parse(response.body)['success']).to eq(false)
      end
    end
  end
  
end
