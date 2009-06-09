# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../spec_helper')

describe NestedAjax::NameToDisplay do
  it "Product#ownership_name_for_nested_ajax" do
    person = Person.create(:name => "akimatter")
    product = Product.create(:name => "nested_ajax")
    ownership = ProductMembership.new(:role_cd => '01')
    ownership.product = product
    ownership.person = person
    ownership.save!
    person.name_for_nested_ajax.should == "akimatter"
    product.name_for_nested_ajax.should == "nested_ajax"
    ownership.name_for_nested_ajax.should == "nested_ajax - akimatter"
    # 
    product.ownership_name_for_nested_ajax.should == "akimatter"
    person.product_membership_names_for_nested_ajax.should == ["nested_ajax"]
    #
    ownership.person_name_for_nested_ajax.should == "akimatter"
    ownership.product_name_for_nested_ajax.should == "nested_ajax"
  end

  it "Product#find_with_name" do
    Product.should_receive(:find).
      with(:all, :conditions => ["name like ?", "%ruby%"], :order => :name).and_return([])
    Product.find_with_name("ruby")
  end
end
