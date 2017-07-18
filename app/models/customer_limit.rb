class CustomerLimit < ActiveRecord::Base
  def self.details(customer_id, co)
    three = 'Sales ' + 3.months.ago.strftime("%B")
    two = 'Sales ' + 2.months.ago.strftime("%B")
    one = 'Sales ' + 1.months.ago.strftime("%B")

    find_by_sql("
      SELECT name, 'Customer' cus FROM customer_limits WHERE address_number = '#{customer_id}' AND co = '#{co}'
      UNION ALL
      SELECT co, 'CO' cos FROM customer_limits WHERE address_number = '#{customer_id}'  AND co = '#{co}'
      UNION ALL
      SELECT FORMAT(credit_limit, 0), 'Credit Limit' lm FROM customer_limits WHERE address_number = '#{customer_id}'  AND co = '#{co}'
      UNION ALL
      SELECT FORMAT(open_amount, 0), 'Open Order' op FROM customer_limits WHERE address_number = '#{customer_id}'  AND co = '#{co}'
      UNION ALL
      SELECT FORMAT(amount_due, 0), 'Amount Due' ad FROM customer_limits WHERE address_number = '#{customer_id}'  AND co = '#{co}'
      UNION ALL
      SELECT FORMAT((credit_limit - (amount_due + open_amount)), 0), 'Balance' bl FROM customer_limits WHERE address_number = '#{customer_id}'  AND co = '#{co}'
      UNION ALL
      SELECT FORMAT(one_month_ago, 0), '#{one}' one FROM customer_limits WHERE address_number = '#{customer_id}' AND co = '#{co}'
      UNION ALL
      SELECT FORMAT(two_months_ago, 0), '#{two}' two FROM customer_limits WHERE address_number = '#{customer_id}'  AND co = '#{co}'
      UNION ALL
      SELECT FORMAT(three_months_ago, 0), '#{three}' three FROM customer_limits WHERE address_number = '#{customer_id}'  AND co = '#{co}'
    ")
  end

end