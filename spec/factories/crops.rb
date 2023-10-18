FactoryBot.define do
    factory :crop do
      crop_name { Faker::Food.vegetables }
      crop_price { rand(1.0..10.0).round(2) }
      crop_status { ["available", "unavailable","expired"].sample }
      crop_expiry_date { Faker::Date.forward(days: 30) }
      crop_quantity { rand(10..100) }
      association :user
    end
  end
  