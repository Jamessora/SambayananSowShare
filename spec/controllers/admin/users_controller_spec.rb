require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
    include Devise::Test::ControllerHelpers
    let(:admin) { create(:admin) }  # Assuming you have a factory for admin

    before do
      sign_in admin  # Sign in the admin user
    end
  
    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(controller.current_admin).to eq(admin)
        expect(response).to be_successful
      end
    end
    # before :each do
    #     @request.env["devise.mapping"] = Devise.mappings[:admin]
    # end
    
# let(:admin) { create(:admin) } 
#   let(:user) { create(:user) }
#   let(:valid_attributes) { attributes_for(:user) }
#   let(:invalid_attributes) { { email: 'invalid' } } # For example

#   before do

#     admin = create(:admin)
#     sign_in admin # Assuming you are using Devise's test helpers
#     puts "Admin signed in: #{admin.inspect}"
    

#   end

#   describe 'GET #index' do
#      let(:admin) { create(:admin) }  # Assuming you have a factory for admin
  
#   before do
    
#     sign_in admin
#   end
  
#     it 'returns a success response' do
#       get :index
#       expect(controller.current_admin).to eq(admin)
#       puts "Admin signed in: #{admin.inspect}"
#       puts "Response: #{response.inspect}"
#       expect(response).to be_successful
#     end
#   end

#   describe 'GET #show' do
#     it 'returns a success response' do
#       get :show, params: { id: user.to_param }
#       puts "Show method called with params debug: #{params[:id]}"
#       expect(response).to be_successful
#     end
#   end

#   describe 'POST #create' do
#     context 'with valid params' do
#       it 'creates a new User' do
#         expect {
#           post :create, params: { user: valid_attributes }
#         }.to change(User, :count).by(1)
#       end

#       it 'renders a JSON response with the new user' do
#         post :create, params: { user: valid_attributes }
#         expect(response).to have_http_status(:ok)
#       end
#     end

#     context 'with invalid params' do
#       it 'does not create a new User' do
#         expect {
#           post :create, params: { user: invalid_attributes }
#         }.to change(User, :count).by(0)
#       end

#       it 'renders a JSON response with errors for the new user' do
#         post :create, params: { user: invalid_attributes }
#         expect(response).to have_http_status(:unprocessable_entity)
#       end
#     end
#   end

#   describe 'PUT #update' do
#     context 'with valid params' do
#       let(:new_attributes) { { fullName: 'Updated Name' } }
  
#       it 'updates the requested user' do
#         put :update, params: { id: user.to_param, user: new_attributes }
#         user.reload
#         expect(user.fullName).to eq('Updated Name')
#       end
  
#       it 'renders a JSON response with the updated user' do
#         put :update, params: { id: user.to_param, user: valid_attributes }
#         expect(response).to have_http_status(:ok)
#       end
#     end
  
#     context 'with invalid params' do
#       it 'renders a JSON response with errors for the user' do
#         put :update, params: { id: user.to_param, user: invalid_attributes }
#         expect(response).to have_http_status(:unprocessable_entity)
#       end
#     end
#   end
  
#   describe 'DELETE #destroy' do
#     it 'destroys the requested user' do
#       user = create(:user)
#       expect {
#         delete :destroy, params: { id: user.to_param }
#       }.to change(User, :count).by(0)
#     end
  
#     it 'renders a JSON response with the deleted user' do
#       user = create(:user)
#       delete :destroy, params: { id: user.to_param }
#       expect(response).to have_http_status(:ok)
#     end
#   end
  
end
