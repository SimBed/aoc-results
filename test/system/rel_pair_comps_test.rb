require "application_system_test_case"

class RelPairCompsTest < ApplicationSystemTestCase
  setup do
    @rel_pair_comp = rel_pair_comps(:one)
  end

  test "visiting the index" do
    visit rel_pair_comps_url
    assert_selector "h1", text: "Rel Pair Comps"
  end

  test "creating a Rel pair comp" do
    visit rel_pair_comps_url
    click_on "New Rel Pair Comp"

    fill_in "Comp", with: @rel_pair_comp.comp_id
    fill_in "Pair", with: @rel_pair_comp.pair_id
    fill_in "Position", with: @rel_pair_comp.position
    fill_in "Score", with: @rel_pair_comp.score
    click_on "Create Rel pair comp"

    assert_text "Rel pair comp was successfully created"
    click_on "Back"
  end

  test "updating a Rel pair comp" do
    visit rel_pair_comps_url
    click_on "Edit", match: :first

    fill_in "Comp", with: @rel_pair_comp.comp_id
    fill_in "Pair", with: @rel_pair_comp.pair_id
    fill_in "Position", with: @rel_pair_comp.position
    fill_in "Score", with: @rel_pair_comp.score
    click_on "Update Rel pair comp"

    assert_text "Rel pair comp was successfully updated"
    click_on "Back"
  end

  test "destroying a Rel pair comp" do
    visit rel_pair_comps_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Rel pair comp was successfully destroyed"
  end
end
