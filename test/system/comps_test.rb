require "application_system_test_case"

class CompsTest < ApplicationSystemTestCase
  setup do
    @comp = comps(:one)
  end

  test "visiting the index" do
    visit comps_url
    assert_selector "h1", text: "Comps"
  end

  test "creating a Comp" do
    visit comps_url
    click_on "New Comp"

    fill_in "Date", with: @comp.date
    click_on "Create Comp"

    assert_text "Comp was successfully created"
    click_on "Back"
  end

  test "updating a Comp" do
    visit comps_url
    click_on "Edit", match: :first

    fill_in "Date", with: @comp.date
    click_on "Update Comp"

    assert_text "Comp was successfully updated"
    click_on "Back"
  end

  test "destroying a Comp" do
    visit comps_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Comp was successfully destroyed"
  end
end
