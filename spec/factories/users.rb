  # spec/factories/users.rb

FactoryBot.define do
    factory :user do
      email { Faker::Internet.email }
      password { 'password123' }
      password_confirmation { 'password123' }
      fullName { Faker::Name.name }
      birthday { 30.years.ago }
      address_country { Faker::Address.country }
      address_city { Faker::Address.city }
      address_baranggay { Faker::Address.secondary_address }
      address_street { Faker::Address.street_address }
      idType { 'Passport' }
      idNumber { Faker::IDNumber.valid }
      kyc_status { ['nil','approved', 'pending', 'rejected'].sample }
  
      trait :with_kyc_pending do
        kyc_status { 'pending' }
      end
  
      trait :with_kyc_approved do
        kyc_status { 'approved' }
      end
  
      trait :with_kyc_rejected do
        kyc_status { 'rejected' }
      end
  
      trait :with_crops do
        after(:create) do |user|
          create_list(:crop, 3, user: user)
        end
      end
    end
  end
  