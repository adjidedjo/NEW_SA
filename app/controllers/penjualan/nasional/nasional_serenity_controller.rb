class Penjualan::Nasional::NasionalSerenityController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :authorize_user
  before_action :retail_nasional_weekly, only: :weekly
  before_action :retail_nasional_monthly, only: :monthly
  
  def weekly
    gon.brand = initialize_brand
    gon.max = 500
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/retail_nasional_weekly"
  end

  def monthly
    gon.brand = initialize_brand
    gon.max = 2000
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/retail_nasional_monthly"
  end

  private

  def initialize_brand
    "SERENITY"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand)
  end
end