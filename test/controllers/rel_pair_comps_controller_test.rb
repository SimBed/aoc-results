require "test_helper"

class RelPairCompsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rel_pair_comp = rel_pair_comps(:one)
  end

  test "should get index" do
    get rel_pair_comps_url
    assert_response :success
  end

  test "should get new" do
    get new_rel_pair_comp_url
    assert_response :success
  end

  test "should create rel_pair_comp" do
    assert_difference('RelPairComp.count') do
      post rel_pair_comps_url, params: { rel_pair_comp: { comp_id: @rel_pair_comp.comp_id, pair_id: @rel_pair_comp.pair_id, position: @rel_pair_comp.position, score: @rel_pair_comp.score } }
    end

    assert_redirected_to rel_pair_comp_url(RelPairComp.last)
  end

  test "should show rel_pair_comp" do
    get rel_pair_comp_url(@rel_pair_comp)
    assert_response :success
  end

  test "should get edit" do
    get edit_rel_pair_comp_url(@rel_pair_comp)
    assert_response :success
  end

  test "should update rel_pair_comp" do
    patch rel_pair_comp_url(@rel_pair_comp), params: { rel_pair_comp: { comp_id: @rel_pair_comp.comp_id, pair_id: @rel_pair_comp.pair_id, position: @rel_pair_comp.position, score: @rel_pair_comp.score } }
    assert_redirected_to rel_pair_comp_url(@rel_pair_comp)
  end

  test "should destroy rel_pair_comp" do
    assert_difference('RelPairComp.count', -1) do
      delete rel_pair_comp_url(@rel_pair_comp)
    end

    assert_redirected_to rel_pair_comps_url
  end
end
