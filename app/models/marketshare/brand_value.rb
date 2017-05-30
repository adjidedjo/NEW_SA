class Marketshare::BrandValue < ActiveRecord::Base
  belongs_to :brand
  belongs_to :area
  belongs_to :customer
  
  validates :brand_id, uniqueness: { scope: [:customer_id, :area_id, :month, :year],  message: " & Area is available" }
  
  def self.sales_marketshare_index(user)
    where("year = ? AND month = ? 
      AND area_id = ?", Date.yesterday.year, Date.yesterday.month, user.branch1).includes(:area, :brand)
  end
  
  def self.bm_marketshare_index(user)
    where("year = ? AND 
      month = ? AND area_id = ?", Date.yesterday.year, Date.yesterday.month, user.branch1).includes(:area, :brand)
  end
  
  def self.admin_marketshare_index
    where("year = ? AND month = ?", Date.yesterday.year, Date.yesterday.month).includes(:area, :brand)
  end
end