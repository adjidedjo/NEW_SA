module ArConcern
  include ApplicationHelper
  extend ActiveSupport::Concern
  
  def retail_collectable_ar_conc
    @u_ar = AccountReceivable.find_collectable(initialize_brand, initialize_brach_id)
    @u_percentage = AccountReceivable.find_collectable_percentage(initialize_brand, initialize_brach_id)
  end
  
  def retail_uncollectable_ar10_conc
    @u_ar10 = AccountReceivable.find_uncollectable10(initialize_brand, initialize_brach_id)
  end
  
  def retail_uncollectable_ar20_conc
    @u_ar20 = AccountReceivable.find_uncollectable20(initialize_brand, initialize_brach_id)
  end
  
  def retail_uncollectable_ar31_conc
    @u_ar31 = AccountReceivable.find_uncollectable31(initialize_brand, initialize_brach_id)
  end
  
  def retail_uncollectable_ar100_conc
    @u_ar100 = AccountReceivable.find_uncollectable100(initialize_brand, initialize_brach_id)
  end
  
end