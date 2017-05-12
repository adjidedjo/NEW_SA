class BasePrice < ActiveRecord::Base
  
  def self.finding_bp_mattress(branch)
    find_by_sql("SELECT * FROM base_prices WHERE branch IN ('#{branch}') AND product = 'KM'")
  end
  
  def self.finding_bp_divan(branch)
    find_by_sql("SELECT * FROM base_prices WHERE branch IN ('#{branch}') AND product IN ('DV', 'HB')")
  end
  
  def self.finding_bp_sorong(branch)
    find_by_sql("SELECT * FROM base_prices WHERE branch IN ('#{branch}') AND product IN ('SA', 'SB', 'ST')")
  end
  
  def self.finding_bp_foam(branch)
    find_by_sql("SELECT * FROM base_prices WHERE branch IN ('#{branch}') AND product = 'KB'")
  end
  
end