class ProductMembership < ActiveRecord::Base
  belongs_to :product
  accepts_nested_attributes_for(:product)

  belongs_to :person
  accepts_nested_attributes_for(:person)
end
