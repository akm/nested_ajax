class Product < ActiveRecord::Base
  name_for_nested_ajax :name

  has_many :memberships, :class_name => 'ProductMembership', :foreign_key => "product_id", :dependent => :destroy
  accepts_nested_attributes_for(:memberships)
end
