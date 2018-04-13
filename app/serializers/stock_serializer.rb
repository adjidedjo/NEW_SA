class StockSerializer < ActiveModel::Serializer
  attributes :id, :onhand, :available, :description, :item_number
end
