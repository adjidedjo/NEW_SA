module RolesHelper
  def branch(user, branch)
    if user.branch1.present? || user.branch2.present?
      return true if user.branch1.to_i == branch || user.branch2.to_i == branch
    else
      return true
    end 
  end
  
  def general_manager(user)
    user.position == "gm" || user.position == "admin"
  end
  
  def nsm(user, brand)
    user.position == "nsm" && user.brand1 == brand
  end
  
  def bm(user, branch, brand)
    user.position == "bm" && (user.branch1.to_i == branch || user.branch2.to_i == branch) 
  end
  
  def sales(user, branch, brand)
    user.position == "sales" && (user.brand1 == brand || user.brand2 == brand) && 
    (user.branch1 == branch || user.branch2 == branch) 
  end
end