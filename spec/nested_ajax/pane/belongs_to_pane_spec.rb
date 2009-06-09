# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../spec_helper')

describe NestedAjax::Pane::BelongsToPane, :type => :helper do
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
        # @template.stub!(:form_authenticity_token).and_return("123456789012345678901234567890")
        @template.nested_ajax_pane(:ownership) do |ownership_pane|
          ownership_pane.pane_id.should == "ownership_#{@ownership.object_id}"
          ownership_pane.form.should == nil
          ownership_pane.form_for(@ownership, :url => {:controller => 'product_memberships', :action => 'update', :id => @ownership.id}) do |f|
            ownership_pane.form.should == f
            ownership_pane.belongs_to(:person) do |pane|
              pane.pane_id.should == "ownership_#{@ownership.object_id}_person"
              pane.parent.should == ownership_pane
              # 
              pane.link_to_new("New person")
            end
          end
        end
        expected = %{
          <form action="
              /product_memberships/update/#{@ownership.id}" class="edit_product_membership" id="edit_product_membership_#{@ownership.id}" method="post">
            <div style="margin:0;padding:0">
              <input name="_method" type="hidden" value="put" />
            </div>
            <a href="javascript:void(0)" id="ownership_#{@ownership.object_id}_person_person_new">New person</a>
            <script type="text/javascript">[br]
            //<![CDATA[[br]
            (function(){
              Event.observe("ownership_#{@ownership.object_id}_person_person_new", "click", function(event){;
                new Ajax.Updater('ownership_#{@ownership.object_id}_person_person_new', '/person/new?
                  nested_ajax%5Bform_name%5D=ownership%5Bperson_attributes%5D&
                  nested_ajax%5Bin_form%5D=true&
                  nested_ajax%5Bpane_id%5D=ownership_#{@ownership.object_id}_person', {
                    asynchronous:true, evalScripts:true, insertion:'after', method:'get'}
                );
                Event.stop(event);}, true);
              })();[br]
            //]]>[br]
            </script>
          </form>
        }
        expected = expected.split(/$/).map{|line| line.gsub(/^\s*/, '')}.join.gsub("[br]", "\n").split(/$/).map{|line| line.gsub(/^\s*/, '')}
        actual = @template.output_buffer.split(/$/).map{|line| line.gsub(/^\s*/, '')}
        actual.length.should == expected.length
        actual.each_with_index do |line, index|
          line.should == expected[index]
        end
        actual.should == expected
      end

      it "association type mismatch" do
        @template.nested_ajax_pane(:product) do |product_pane|
          product_pane.form_for(@product, :url => {:controller => 'products', :action => 'update', :id => @product.id}) do |f|
            lambda{
              product_pane.belongs_to(:memberships) do |pane|
                ""
              end
            }.should raise_error(ArgumentError)
            ""
          end
        end
      end
    end
  
  end
end
