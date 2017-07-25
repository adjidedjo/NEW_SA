class Marketshare < ActiveRecord::Base
  has_many :marketshare_brands, dependent: :destroy
  accepts_nested_attributes_for :marketshare_brands, reject_if: :all_blank, allow_destroy: true
  belongs_to :customer, optional: true

  validates :start_date, :end_date, presence: true
  validates :city, presence: true, on: :create

  before_save :upcase_fields
  def upcase_fields
    self.marketshare_brands.each do |bv|
      bv.area_id = self.area_id
      bv.internal_brand = self.brand
      bv.customer_name = self.customer_name
      bv.city = self.city.upcase!
      bv.start_date = self.start_date
      bv.end_date = self.end_date
      bv.name.upcase!
      Brand.where(name: bv.name).first_or_create if bv.name.present?
    end
    self.city.upcase!
  end

  def customer_name
    customer.try(:name)
  end

  def customer_name=(name)
    self.customer = Customer.where(name: name).first_or_create if name.present?
  end

  def self.list_customers(user)
    user = User.find(user)
    find_by_sql("SELECT ms.* FROM marketshares ms
      WHERE ms.area_id = '#{user.branch1.nil? ? 0 : user.branch1}'")
  end

  def self.get_report(brand, branch)
    a = []
    t = find_by_sql("SELECT SUM(amount) as data, name FROM marketshare_brands WHERE area_id = 2 AND internal_brand = '#{brand}'
    GROUP BY internal_brand, name
    UNION
    SELECT SUM(harganetto2) as data, jenisbrgdisc FROM tblaporancabang WHERE area_id = 2
    AND jenisbrgdisc = '#{brand}' AND fiscal_month = '#{Date.yesterday.month}'
    AND fiscal_year = '#{Date.yesterday.year}'
    GROUP BY jenisbrgdisc")
    t.each_with_object({}) do |forecast, hash|
      c = {"label" => forecast.name}
      a2 = {"data" => forecast.data}
      a << c.merge(a2)
    end
    return a
  end

end
