module MarketsharesHelper
  def find_customer(customer)
    Customer.find(customer)
  end
  
  def find_period(per)
    Period.find(per).desc
  end
end
