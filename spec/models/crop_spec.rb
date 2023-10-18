require 'rails_helper'

RSpec.describe Crop, type: :model do
  it { should belong_to(:user) }
  
  it { should validate_presence_of(:crop_name) }
  it { should validate_presence_of(:crop_price) }
  it { should validate_numericality_of(:crop_price).is_greater_than(0) }
  it { should validate_inclusion_of(:crop_status).in_array(['available', 'unavailable', 'expired']) }
  it { should validate_presence_of(:crop_expiry_date) }
  it { should validate_presence_of(:crop_quantity) }
  it { should validate_numericality_of(:crop_quantity).only_integer }
end
