require "test_helper"

class CompsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comp = comps(:one)
  end

  test "should get index" do
    get comps_url
    assert_response :success
  end

  test "should get new" do
    get new_comp_url
    assert_response :success
  end

  test "should create comp" do
    assert_difference('Comp.count') do
      post comps_url, params: { comp: { date: @comp.date } }
    end

    assert_redirected_to comp_url(Comp.last)
  end

  test "should show comp" do
    get comp_url(@comp)
    assert_response :success
  end

  test "should get edit" do
    get edit_comp_url(@comp)
    assert_response :success
  end

  test "should update comp" do
    patch comp_url(@comp), params: { comp: { date: @comp.date } }
    assert_redirected_to comp_url(@comp)
  end

  test "should destroy comp" do
    assert_difference('Comp.count', -1) do
      delete comp_url(@comp)
    end

    assert_redirected_to comps_url
  end
end
