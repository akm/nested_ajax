# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../spec_helper')

describe NestedAjax::Pane::SinglePane, :type => :helper do
  include NestedAjax::BaseHelper
  
  before(:each) do
    @template.output_buffer = ""
  end

  describe "for unsaved model" do
    before(:each) do
      @person = Person.new
      @template.instance_variable_set(:@person, @person)
    end

    describe "link_to_new_cancel" do
      it "default" do
        @template.nested_ajax_pane(:person) do |pane|
          pane.pane_id.should == "person_#{@person.object_id}"
          pane.link_to_new_cancel("Cancel").should == 
            "<a href=\"#\" onclick=\"Element.remove('#{pane.pane_id}'); return false;\">Cancel</a>"
        end
      end

      it "with a tag options" do
        @template.nested_ajax_pane(:person) do |pane|
          pane.pane_id.should == "person_#{@person.object_id}"
          pane.link_to_new_cancel("Cancel", :class => "commands").should == 
            "<a class=\"commands\" href=\"#\" onclick=\"Element.remove('#{pane.pane_id}'); return false;\">Cancel</a>"
        end
      end
    end
  end

  describe "for saved model" do
    before(:each) do
      @product = Product.create(:name => 'nested_ajax')
      @template.instance_variable_set(:@product, @product)
    end

    describe "link_to_show" do
      it "default" do
        @template.nested_ajax_pane(:product) do |pane|
          pane.pane_id.should == "product_#{@product.object_id}"
          script = %{ 
            new Ajax.Updater('#{pane.pane_id}', 
              '/helper_example_group/show/#{@product.id}?
                #{CGI.escape("nested_ajax[foreign_key]")}=&amp;
                #{CGI.escape("nested_ajax[form_name]")}=product&amp;
                #{CGI.escape("nested_ajax[in_form]")}=false&amp;
                #{CGI.escape("nested_ajax[pane_id]")}=#{pane.pane_id}', 
              {asynchronous:true, evalScripts:true, method:'get'}
            ); 
            return false;
          }.split(/$/).map{|line| line.gsub(/^\s*/, '')}.join
          pane.link_to_show("Show").should == 
            "<a href=\"#\" onclick=\"#{script}\">Show</a>"
        end
      end
    end

    describe "link_to_edit_cancel" do
      it "default" do
        @template.nested_ajax_pane(:product) do |pane|
          pane.pane_id.should == "product_#{@product.object_id}"
          script = %{ 
            new Ajax.Updater('#{pane.pane_id}', 
              '/helper_example_group/show/#{@product.id}?
                #{CGI.escape("nested_ajax[foreign_key]")}=&amp;
                #{CGI.escape("nested_ajax[form_name]")}=product&amp;
                #{CGI.escape("nested_ajax[in_form]")}=false&amp;
                #{CGI.escape("nested_ajax[pane_id]")}=#{pane.pane_id}', 
              {asynchronous:true, evalScripts:true, method:'get'}
            ); 
            return false;
          }.split(/$/).map{|line| line.gsub(/^\s*/, '')}.join
          pane.link_to_edit_cancel("Cancel").should == 
            "<a href=\"#\" onclick=\"#{script}\">Cancel</a>"
        end
      end
    end

    describe "link_to_edit" do
      it "default" do
        @template.nested_ajax_pane(:product) do |pane|
          pane.pane_id.should == "product_#{@product.object_id}"
          script = %{ 
            new Ajax.Updater('#{pane.pane_id}', 
              '/helper_example_group/edit/#{@product.id}?
                #{CGI.escape("nested_ajax[foreign_key]")}=&amp;
                #{CGI.escape("nested_ajax[form_name]")}=product&amp;
                #{CGI.escape("nested_ajax[in_form]")}=false&amp;
                #{CGI.escape("nested_ajax[pane_id]")}=#{pane.pane_id}', 
              {asynchronous:true, evalScripts:true, method:'get'}
            ); 
            return false;
          }.split(/$/).map{|line| line.gsub(/^\s*/, '')}.join
          pane.link_to_edit("Edit").should == 
            "<a href=\"#\" onclick=\"#{script}\">Edit</a>"
        end
      end
    end


    describe "link_to_destroy" do
      it "default" do
        @template.nested_ajax_pane(:product) do |pane|
          pane.pane_id.should == "product_#{@product.object_id}"
          script = %{ 
            new Ajax.Updater('#{pane.pane_id}', 
              '/helper_example_group/destroy/#{@product.id}?
                #{CGI.escape("nested_ajax[foreign_key]")}=&amp;
                #{CGI.escape("nested_ajax[form_name]")}=product&amp;
                #{CGI.escape("nested_ajax[in_form]")}=false&amp;
                #{CGI.escape("nested_ajax[pane_id]")}=#{pane.pane_id}', 
              {asynchronous:true, evalScripts:true, method:'delete'}
            ); 
            return false;
          }.split(/$/).map{|line| line.gsub(/^\s*/, '')}.join
          pane.link_to_destroy("Delete").should == 
            "<a href=\"#\" onclick=\"#{script}\">Delete</a>"
        end
      end

      it "with effect" do
        @template.nested_ajax_pane(:product) do |pane|
          pane.pane_id.should == "product_#{@product.object_id}"
          script = %{ 
            new Ajax.Updater('#{pane.pane_id}', 
              '/helper_example_group/destroy/#{@product.id}?
                #{CGI.escape("nested_ajax[foreign_key]")}=&amp;
                #{CGI.escape("nested_ajax[form_name]")}=product&amp;
                #{CGI.escape("nested_ajax[in_form]")}=false&amp;
                #{CGI.escape("nested_ajax[pane_id]")}=#{pane.pane_id}', 
              {asynchronous:true, evalScripts:true, method:'delete', onSuccess:function(request){new Effect.Highlight('#{pane.pane_id}')}}
            ); 
            return false;
          }.split(/$/).map{|line| line.gsub(/^\s*/, '')}.join
          pane.link_to_destroy("Delete", :effect => "new Effect.Highlight('#{pane.pane_id}')").should == 
            "<a href=\"#\" onclick=\"#{script}\">Delete</a>"
        end
      end
    end

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

    describe "belongs_to" do
      it "default" do
        @template.nested_ajax_pane(:ownership) do |ownership_pane|
          ownership_pane.pane_id.should == "ownership_#{@ownership.object_id}"
          ownership_pane.form.should == nil
          ownership_pane.form_for(@ownership, :url => {:controller => 'product_memberships', :action => 'update', :id => @ownership.id}) do |f|
            ownership_pane.form.should == f
            ownership_pane.belongs_to(:person) do |pane|
              pane.pane_id.should == "ownership_#{@ownership.object_id}_person"
              pane.parent.should == ownership_pane
              ""
            end
          end
        end
        @template.output_buffer.should == %{
          <form action="
              /product_memberships/update/#{@ownership.id}" class="edit_product_membership" id="edit_product_membership_#{@ownership.id}" method="post">
            <div style="margin:0;padding:0">
              <input name="_method" type="hidden" value="put" />
            </div>
          </form>
        }.split(/$/).map(&:strip).join
      end

      it "without form" do
        lambda{
          @template.nested_ajax_pane(:ownership) do |ownership_pane|
            ownership_pane.belongs_to(:person) do |pane|
              ""
            end
          end
        }.should raise_error(NestedAjax::UsageError)
      end
    end
  
    describe "has_many" do
      it "default" do
        @template.nested_ajax_pane(:product) do |product_pane|
          product_pane.pane_id.should == "product_#{@product.object_id}"
          product_pane.has_many(:memberships) do |pane|
            pane.pane_id.should == "product_#{@product.object_id}"
            pane.parent.should == product_pane
            ""
          end
        end
        @template.output_buffer.should == ""
      end
    end

  end

  

end
