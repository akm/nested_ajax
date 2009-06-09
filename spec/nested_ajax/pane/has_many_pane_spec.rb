# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../spec_helper')

describe NestedAjax::Pane::HasManyPane, :type => :helper do
  include NestedAjax::BaseHelper
  
  before(:each) do
    @template.output_buffer = ""
  end
  
  describe "pane association" do
    before(:each) do
      @person = Person.create(:name => "akimatter")
      @product = Product.create(:name => "nested_ajax")
      @ownership = ProductMembership.new(:role_cd => '01')
      @ownership.product = @product
      @ownership.person = @person
      @ownership.save!
      @template.instance_variable_set(:@person, @person)
      @template.instance_variable_set(:@product, @product)
      @template.instance_variable_set(:@ownership, @ownership)
    end

    describe "normal usage" do
      it "default" do
        @template.nested_ajax_pane(:product) do |product_pane|
          product_pane.pane_id.should == "product_#{@product.object_id}"
          product_pane.has_many(:memberships) do |pane|
            pane.class.should == NestedAjax::Pane::HasManyPane
            pane.pane_id.should == "product_#{@product.object_id}"
            pane.parent.should == product_pane
            count = 0
            pane.each do |membership_pane|
              count += 1
              membership_pane.class.should == NestedAjax::Pane::SinglePane
              membership_pane.pane_id.should == "product_membership_#{membership_pane.object.object_id}"
              membership_pane.parent.should == pane
              @template.concat("pane_id is #{membership_pane.pane_id}") 
            end
            count.should == 1
            @template.concat(pane.link_to_new("New membership"))
            ""
          end
        end

        expected = <<-"EOS"
          <div class="nested_ajax " id="product_membership_#{@product.memberships.first.object_id}">
            pane_id is product_membership_#{@product.memberships.first.object_id}
          </div>
          <a href="javascript:void(0)" id="product_#{@product.object_id}_memberships_new">New membership</a>
          <script type="text/javascript">[br]
          //<![CDATA[[br]
            (function(){
              var base_script = "new Ajax.Updater('product_#{@product.object_id}_memberships_new', '/memberships/new?
                #{CGI.escape("nested_ajax[foreign_key]")}=product_id&
                #{CGI.escape("nested_ajax[form_name]")}=#{CGI.escape("product[memberships_attributes][**child_index**]")}&
                #{CGI.escape("nested_ajax[in_form]")}=false&
                #{CGI.escape("nested_ajax[pane_id]")}=product_#{@product.object_id}_#{CGI.escape("**child_index**")}&
                #{CGI.escape("product_membership[product_id]")}=11', {
                  asynchronous:true, evalScripts:true, insertion:'before', method:'get'})";
              var child_index = 2;
              var child_index_holder = new RegExp(RegExp.escape("%2A%2Achild_index%2A%2A"));
              Event.observe("product_#{@product.object_id}_memberships_new", "click", function(event){
                var script = base_script.gsub(child_index_holder, child_index);
                eval(script);
                child_index++;Event.stop(event);
              }, true);
            })();[br]
          //]]>[br]
          </script>
        EOS
        expected = expected.split(/$/).map{|line| line.gsub(/^\s*/, '')}.join.gsub("[br]", "\n").split(/$/).map{|line| line.gsub(/^\s*/, '')}
        actual = @template.output_buffer.split(/$/).map{|line| line.gsub(/^\s*/, '')}
        actual.length.should == expected.length
        actual.each_with_index do |line, index|
          line.should == expected[index]
        end
        actual.should == expected
      end
    
    end

    describe "association type mismatch" do
      it "default" do
        @template.nested_ajax_pane(:ownership) do |ownership_pane|
          lambda{
            ownership_pane.has_many(:product) do |pane|
              ""
            end
          }.should raise_error(ArgumentError)
        end
      end
    
    end

  end

end
