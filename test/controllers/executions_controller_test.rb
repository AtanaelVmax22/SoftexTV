require "test_helper"

class ExecutionsControllerTest < ActionDispatch::IntegrationTest
  test "should get execute" do
    get executions_execute_url
    assert_response :success
  end
end
