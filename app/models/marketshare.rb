class Marketshare < ApplicationRecord
  has_many :brand_values, dependent: :destroy
  accepts_nested_attributes_for :brand_values, reject_if: :all_blank, allow_destroy: true
  belongs_to :customer

  validates :start_date, :end_date, presence: true
  validates :city, presence: true, on: :create

  before_save :upcase_fields
  
  def customer_name
    customer.try(:name)
  end
  
  def customer_name=(name)
    self.customer = Customer.where(name: name).first_or_create if name.present?
  end
  
  def upcase_fields
    self.brand_values.each do |bv|
      bv.customer_name = self.customer_name
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
