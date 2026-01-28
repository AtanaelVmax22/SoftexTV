require "test_helper"

class StreamingConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @streaming_configuration = streaming_configurations(:one)
  end

  test "should get index" do
    get streaming_configurations_url
    assert_response :success
  end

  test "should get new" do
    get new_streaming_configuration_url
    assert_response :success
  end

  test "should create streaming_configuration" do
    assert_difference("StreamingConfiguration.count") do
      post streaming_configurations_url, params: { streaming_configuration: {  } }
    end

    assert_redirected_to streaming_configuration_url(StreamingConfiguration.last)
  end

  test "should show streaming_configuration" do
    get streaming_configuration_url(@streaming_configuration)
    assert_response :success
  end

  test "should get edit" do
    get edit_streaming_configuration_url(@streaming_configuration)
    assert_response :success
  end

  test "should update streaming_configuration" do
    patch streaming_configuration_url(@streaming_configuration), params: { streaming_configuration: {  } }
    assert_redirected_to streaming_configuration_url(@streaming_configuration)
  end

  test "should destroy streaming_configuration" do
    assert_difference("StreamingConfiguration.count", -1) do
      delete streaming_configuration_url(@streaming_configuration)
    end

    assert_redirected_to streaming_configurations_url
  end
end
