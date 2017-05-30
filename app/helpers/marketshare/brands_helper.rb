module Marketshare::BrandsHelper
  
  def brand_status(status)
    status == true ? 'External' : 'Internal'
  end
end