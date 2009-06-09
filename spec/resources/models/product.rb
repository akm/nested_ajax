class Product < ActiveRecord::Base
  name_for_nested_ajax :name

  has_one :ownership, :class_name => 'ProductMembership', :foreign_key => "product_id", :conditions => "role_cd = '01'"

  has_many :memberships, :class_name => 'ProductMembership', :foreign_key => "product_id", :dependent => :destroy
  accepts_nested_attributes_for(:memberships)

end
