class BranchProduction < ActiveRecord::Base
  establish_connection :sales_mart
  self.table_name = "BRANCH_PRODUCTIONS"
  
end