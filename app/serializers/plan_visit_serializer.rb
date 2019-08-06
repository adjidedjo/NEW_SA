class PlanVisitSerializer < ActiveModel::Serializer
  attributes :id, :sales_id, :brand, :city, :date_visit, :customer, :hotel, :accomodation, :allowance
end
