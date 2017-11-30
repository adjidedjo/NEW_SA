class IndonesiaCity < ActiveRecord::Base
  validates :name, :area_id, presence: true
  
  after_destroy :destroy_marketshare
  
  def destroy_marketshare
    Marketshare.where(city: self.name).destroy_all
    MarketshareBrand.where(city: self.name).destroy_all
  end
end