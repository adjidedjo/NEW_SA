class AccountReceivables::Bali::EliteArController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user, :branch_name
  before_action :retail_uncollectable_ar, only: :uncollectable_ar
  before_action :retail_collectable_ar, only: :collectable_ar
  
  def uncollectable_ar
    @branch_name = branch_name
    @brand_name = initialize_brand
    @branch = initialize_brach_id
    render template: "account_receivables/templates/uncollectable"
  end
  
  def collectable_ar
    @branch_name = branch_name
    @brand_name = initialize_brand
    @branch = initialize_brach_id
    render template: "account_receivables/templates/collectable"
  end
  
  private
  
  def branch_name
    "Bali"
  end

  def initialize_brand
    "ELITE"
  end

  def initialize_brach_id
    4
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm(current_user, initialize_brach_id, initialize_brand) || sales(current_user, initialize_brach_id, initialize_brand)
  end
end