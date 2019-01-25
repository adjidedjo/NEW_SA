class Api::CarLog < ActiveRecord::Base
  validates :nopol, :jumlah_check, :nopos, presence: true
  validates :nopol, uniqueness: {scope: [:jumlah_check, :nopos, :created_at]}
end