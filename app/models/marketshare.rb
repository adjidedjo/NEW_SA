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

  def self.get_area_potential(brand, branch)
    find_by_sql("
      SELECT ct.area, lp.w1, lp.w2, mt.potent, ((lp.w2/mt.potent) * 100) AS market, 
      (((lp.w2 - lp.w1) / lp.w1) * 100) as grow FROM
      (
        SELECT kota AS area FROM tblaporancabang WHERE area_id = '#{branch}' AND
        fiscal_month BETWEEN '#{1.month.ago.month}' AND '#{Date.today.month}' AND
        fiscal_year BETWEEN '#{1.month.ago.year}' AND '#{Date.today.year}'
        AND jenisbrgdisc = '#{brand}' AND tipecust = 'RETAIL' AND bonus = '-' AND
        kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND kota != ' ' GROUP BY kota
      ) AS ct
      LEFT JOIN
      (
        SELECT kota AS area,
        SUM(CASE WHEN week = '#{1.week.ago.to_date.cweek}' THEN harganetto2 END) AS w1,
        SUM(CASE WHEN week = '#{Date.today.cweek}' THEN harganetto2 END) AS w2 FROM
        tblaporancabang WHERE week BETWEEN '#{1.week.ago.to_date.cweek}' AND '#{Date.today.cweek}' AND
        jenisbrgdisc LIKE '#{brand}' AND area_id = '#{branch}'
        AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') AND area_id NOT IN (1,50)
        AND tipecust = 'RETAIL' GROUP BY kota
      ) AS lp ON ct.area = lp.area
      LEFT JOIN
      (
        SELECT SUM(amount) AS potent, city FROM marketshare_brands WHERE internal_brand = '#{brand}'
        AND area_id = '#{branch}'
      ) AS mt ON mt.city = ct.area
    ")
  end

  def self.get_report(brand, branch)
    a = []
    t = find_by_sql("SELECT SUM(amount) as data, name FROM marketshare_brands WHERE area_id = '#{branch}'
    AND internal_brand = '#{brand}'
    GROUP BY internal_brand, name
    UNION
    SELECT SUM(harganetto2) as data, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}'
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
