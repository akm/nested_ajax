class Person < ActiveRecord::Base
  name_for_nested_ajax :name

  has_many :product_memberships
  accepts_nested_attributes_for(:product_memberships)
end
