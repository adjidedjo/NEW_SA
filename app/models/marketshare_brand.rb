class MarketshareBrand < ActiveRecord::Base
  belongs_to :marketshare,  inverse_of: :marketshares
end