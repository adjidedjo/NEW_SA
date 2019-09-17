module RolesHelper
  def branch(user, branch)
    if user.branch1.present? || user.branch2.present?
      return true if user.branch1.to_i == branch || user.branch2.to_i == branch
    else
      return true
    end 
  end
  
  def reg1(user, num)
    if user.regional == num
      return true
    elsif user.regional == nil
      return true
    end  
  end
  
  def general_manager(user)
    user.position == "gm" || user.position == "owner" || user.position == "admin" || 
    user.position == "marketing pusat" || user.position == "admin marketing" || user.position == "akunting pusat"
  end
  
  def nsm_customers(user)
    (user.position == "nsm" || user.position == "sales support")
  end
  
  def bm_customers(user, branch)
    (user.position == "bm" || user.position == "admin sales" || user.position == "accounting") && (user.branch1.to_i == branch || user.branch2.to_i == branch) 
  end
  
  def nsm(user, brand)
    brand = brand.split("|").first
    (user.position == "nsm" || user.position == "sales support") && user.brand1 == brand
  end
  
  def bm(user, branch, brand)
    brand = brand.split("|").first
    (user.position == "bm" || user.position == "admin sales" || user.position == "accounting") && (user.branch1.to_i == branch || user.branch2.to_i == branch) 
  end
  
  def report_all_brand(user)
    user.position == "gm" || user.position == "owner" || user.position == "admin" || user.position == "nsm"
  end
  
  def sales(user, branch, brand)
    brand = brand.split("|").first
    user.position == "sales" && (user.brand1 == brand || user.brand2 == brand || user.brand3 == brand || user.brand4 == brand) && 
    (user.branch1 == branch || user.branch2 == branch) 
  end
  
  def sales_credit_limit(user, branch1, branch2)
    user.position == "sales" && (user.branch1 == branch1 || user.branch2 == branch2) 
  end
  
  def sales_page(user, brand)
    brand = brand.split("|").first
    user.position == "sales" && (user.brand1 == brand || user.brand2 == brand || user.brand3 == brand || user.brand4 == brand)
  end
  
  def nsm_direct(user)
    (user.position == "direct_mng" || user.position == "sales support")
  end
  
  def nsm_modern(user)
    (user.position == "modern_mng" || user.position == "sales support")
  end
end
