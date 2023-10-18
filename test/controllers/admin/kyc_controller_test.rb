require "test_helper"

class Admin::KycControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_kyc_index_url
    assert_response :success
  end

  test "should get approve" do
    get admin_kyc_approve_url
    assert_response :success
  end

  test "should get reject" do
    get admin_kyc_reject_url
    assert_response :success
  end
end
