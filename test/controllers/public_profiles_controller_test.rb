require "test_helper"

class PublicProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get public_profiles_show_url
    assert_response :success
  end
end
