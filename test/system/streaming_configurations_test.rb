require "application_system_test_case"

class StreamingConfigurationsTest < ApplicationSystemTestCase
  setup do
    @streaming_configuration = streaming_configurations(:one)
  end

  test "visiting the index" do
    visit streaming_configurations_url
    assert_selector "h1", text: "Streaming configurations"
  end

  test "should create streaming configuration" do
    visit streaming_configurations_url
    click_on "New streaming configuration"

    click_on "Create Streaming configuration"

    assert_text "Streaming configuration was successfully created"
    click_on "Back"
  end

  test "should update Streaming configuration" do
    visit streaming_configuration_url(@streaming_configuration)
    click_on "Edit this streaming configuration", match: :first

    click_on "Update Streaming configuration"

    assert_text "Streaming configuration was successfully updated"
    click_on "Back"
  end

  test "should destroy Streaming configuration" do
    visit streaming_configuration_url(@streaming_configuration)
    click_on "Destroy this streaming configuration", match: :first

    assert_text "Streaming configuration was successfully destroyed"
  end
end
