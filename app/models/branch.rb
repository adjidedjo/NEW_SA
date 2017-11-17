class Branch < ActiveRecord::Base
  self.table_name = "tbidcabang" #dr
  
  def self.get_cabang(branch)
    find_by_id(branch).Cabang.gsub(/Cabang /, '')
  end
end