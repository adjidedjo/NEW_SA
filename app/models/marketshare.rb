class Marketshare < ActiveRecord::Base
  has_many :marketshare_brands, dependent: :destroy
  accepts_nested_attributes_for :marketshare_brands, reject_if: :all_blank, allow_destroy: true
  belongs_to :customer, optional: true

  validates :start_date, :end_date, presence: true
  validates :city, presence: true, on: :create
  validate :checking_city, on: :create
  def checking_city
    id = IndonesiaCity.find_by_city(self.city)
    return errors.add(:city, "Kota yang anda pilih tidak terdaftar") if id.nil?
  end

  before_save :upcase_fields

  def upcase_fields
    id = IndonesiaCity.find_by_city(self.city)
    internal_brand = Brand.find_by_name(self.brand)
    self.marketshare_brands.each do |bv|
      bv.area_id = id.area_id
      bv.internal_brand = self.brand
      bv.customer_name = self.customer_name
      bv.city = id.name
      bv.start_date = self.start_date
      bv.end_date = self.end_date
      bv.name.upcase!
      new_brand = Brand.where(name: bv.name).first
      Brand.create!(name: bv.name, brand_type_id: internal_brand.brand_type_id, external: 1) if new_brand.nil?
    end
    self.city = id.name
    self.area_id = id.area_id
  end

  def customer_name
    customer.try(:name)
  end

  def customer_name=(name)
    self.customer = Customer.where(name: name).first_or_create if name.present?
  end

  def self.list_customers(user)
    user = User.find(user)
    if user.branch1.nil?
      find_by_sql("SELECT ms.* FROM marketshares ms")
    else
      find_by_sql("SELECT ms.* FROM marketshares ms
        WHERE '#{user.branch1.nil? ? 'ms.area_id >= 0' : user.branch1}'")
    end
  end

  def self.get_area_potential(brand, branch)
    week3 = 3.week.ago.to_date.cweek
    week2 = 2.week.ago.to_date.cweek
    week1 = 1.week.ago.to_date.cweek
    find_by_sql("
      SELECT ct.siti, ct.area, lp.w1, lp.w2, lp.w3, mt.potent, ((lp.w1/mt.potent) * 100) AS market,
      (((lp.w1 - lp.w2) / lp.w2) * 100) as grow FROM
      (
        SELECT city AS siti, name AS area FROM indonesia_cities WHERE area_id = '#{branch}'
      ) AS ct
      LEFT JOIN
      (
        SELECT kota AS area,
        SUM(CASE WHEN week = '#{week3}' AND fiscal_year = ('#{week3 > 2 ? Date.today.last_year.year : Date.today.year}') THEN harganetto2 END) AS w3,
        SUM(CASE WHEN week = '#{2.week.ago.to_date.cweek}' AND fiscal_year = ('#{week2 > 2 ? Date.today.last_year.year : Date.today.year}') THEN harganetto2 END) AS w2,
        SUM(CASE WHEN week = '#{1.week.ago.to_date.cweek}' AND fiscal_year = ('#{week1 <= 2 ? Date.today.year : Date.today.last_year.year}') THEN harganetto2 END) AS w1 FROM
        tblaporancabang WHERE jenisbrgdisc LIKE '#{brand}' AND area_id = '#{branch}'
        AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') AND area_id NOT IN (1,50)
        AND tipecust = 'RETAIL' GROUP BY kota
      ) AS lp ON ct.area = lp.area
      LEFT JOIN
      (
        SELECT SUM(amount) AS potent, city FROM marketshare_brands WHERE internal_brand = '#{brand}'
        AND area_id = '#{branch}' GROUP BY city
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
