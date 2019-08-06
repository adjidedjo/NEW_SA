require 'test_helper'

class PlanVisitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plan_visit = plan_visits(:one)
  end

  test "should get index" do
    get plan_visits_url
    assert_response :success
  end

  test "should get new" do
    get new_plan_visit_url
    assert_response :success
  end

  test "should create plan_visit" do
    assert_difference('PlanVisit.count') do
      post plan_visits_url, params: { plan_visit: { accomodation: @plan_visit.accomodation, allowance: @plan_visit.allowance, brand: @plan_visit.brand, city: @plan_visit.city, customer: @plan_visit.customer, date_visit: @plan_visit.date_visit, hotel: @plan_visit.hotel, sales_id: @plan_visit.sales_id } }
    end

    assert_redirected_to plan_visit_url(PlanVisit.last)
  end

  test "should show plan_visit" do
    get plan_visit_url(@plan_visit)
    assert_response :success
  end

  test "should get edit" do
    get edit_plan_visit_url(@plan_visit)
    assert_response :success
  end

  test "should update plan_visit" do
    patch plan_visit_url(@plan_visit), params: { plan_visit: { accomodation: @plan_visit.accomodation, allowance: @plan_visit.allowance, brand: @plan_visit.brand, city: @plan_visit.city, customer: @plan_visit.customer, date_visit: @plan_visit.date_visit, hotel: @plan_visit.hotel, sales_id: @plan_visit.sales_id } }
    assert_redirected_to plan_visit_url(@plan_visit)
  end

  test "should destroy plan_visit" do
    assert_difference('PlanVisit.count', -1) do
      delete plan_visit_url(@plan_visit)
    end

    assert_redirected_to plan_visits_url
  end
end
