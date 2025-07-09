require "test_helper"

class PoemsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get poems_new_url
    assert_response :success
  end

  test "should get create" do
    get poems_create_url
    assert_response :success
  end

  test "should get show" do
    get poems_show_url
    assert_response :success
  end

  test "should get index" do
    get poems_index_url
    assert_response :success
  end
end
