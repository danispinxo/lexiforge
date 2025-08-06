require 'test_helper'

class SourceTextsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get source_texts_index_url
    assert_response :success
  end

  test 'should get show' do
    get source_texts_show_url
    assert_response :success
  end
end
