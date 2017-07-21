class Marketshare < ApplicationRecord
  has_many :brand_values, dependent: :destroy
  accepts_nested_attributes_for :brand_values, reject_if: :all_blank, allow_destroy: true

  validates :customer_id, :start_date, :end_date, presence: true
  validates :city, presence: true, on: :create

  before_save :upcase_fields
  
  def upcase_fields
    self.brand_values.each do |bv|
      bv.customer_id = self.customer_id
      bv.period_id = self.period_id
      bv.city = self.city.upcase!
      bv.start_date = self.start_date
      bv.end_date = self.end_date
      bv.name.upcase!
    end
    self.city.upcase!
  end

  def self.list_customers(user)
    user = User.find(user)
    find_by_sql("SELECT ms.* FROM marketshares ms
      WHERE ms.area_id = '#{user.branch1.nil? ? 0 : user.branch1}'")
  end
  
  def closest(arr, target)
    return nil if arr.empty?
    e = arr.map(&:to_i).sort.to_enum
    x = nil # initialize to anything 
    loop do
      x = e.next
      break if x > target || e.peek > target
    end
    x.to_s
  end
end
