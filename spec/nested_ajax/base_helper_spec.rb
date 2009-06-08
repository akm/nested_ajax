# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../spec_helper')

describe NestedAjax::BaseHelper, :type => :helper do
  include NestedAjax::BaseHelper

  before(:each) do
    @template.output_buffer = ""
  end

  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(NestedAjax::BaseHelper)
  end
  
  describe "nested_ajax_options" do
    it "should be abled to use as template method" do
      @template.respond_to?(:nested_ajax_options)
    end

    describe "return Hash from params" do
      
      describe "default without params['nested_ajax']" do
        it "should return empty Hash if nil" do
          @template.nested_ajax_options.should == {}
        end
      end

      describe "with params['nested_ajax'] Symbol key" do
        before(:each) do
          params['nested_ajax'] = {:foo => 'FOO'}
        end

        it "should return Hash which can be accessed by Symbol" do
          @template.nested_ajax_options.should == {'foo' => 'FOO'}
          @template.nested_ajax_options[:foo].should == "FOO"
        end
      end

      describe "with params['nested_ajax'] String key" do
        before(:each) do
          params['nested_ajax'] = {'foo' => 'FOO'}
        end

        it "should return Hash which can be accessed by Symbol 2" do
          @template.nested_ajax_options.should == {'foo' => 'FOO'}
          @template.nested_ajax_options[:foo].should == "FOO"
        end
      end
    end
  end
  
  describe "nested_ajax_pane" do
    it "should be abled to use as template method" do
      @template.respond_to?(:nested_ajax_pane)
    end
    
    describe "without local pane object" do
      it "when given object_name" do
        membership = ProductMembership.new
        @template.instance_variable_set(:@membership, membership)
        @template.nested_ajax_pane(membership) do |pane|
          pane.parent.should == nil
          pane.object.should == membership
          pane.object_name.should == 'product_membership'
          pane.form.should == nil
          pane.form_name.should == 'product_membership'
          pane.pane_id.should == "product_membership_#{membership.object_id}"
          pane.controller == 'product_membership'
          pane.foreign_key == nil
        end
        # 何もしなければ何も出力されません
        @template.output_buffer.should == ""
      end

      it "when given object" do
        membership = ProductMembership.new
        @template.instance_variable_set(:@membership, membership)
        @template.nested_ajax_pane(:membership) do |pane|
          pane.parent.should == nil
          pane.object.should == membership
          pane.object_name.should == :membership
          pane.form.should == nil
          pane.form_name.should == :membership
          pane.pane_id.should == "membership_#{membership.object_id}"
          pane.controller == 'product_membership'
          pane.foreign_key == nil
        end
        # 何もしなければ何も出力されません
        @template.output_buffer.should == ""
      end
    end

    
    describe "with local pane object" do
      it "when given object_name" do
        membership = ProductMembership.new
        @template.instance_variable_set(:@membership, membership)
        @template.nested_ajax_pane(membership) do |pane|
          pane.parent.should == nil
          pane.object.should == membership
          pane.object_name.should == 'product_membership'
          pane.form.should == nil
          pane.form_name.should == 'product_membership'
          pane.pane_id.should == "product_membership_#{membership.object_id}"
          pane.controller == 'product_membership'
          pane.foreign_key == nil

          person = Person.new
          cascading_nested_ajax_pane = pane
          @template.nested_ajax_pane(person) do |cascading|
            pane.parent.should == nil
            pane.object.should == membership
            pane.object_name.should == 'product_membership'
            pane.form.should == nil
            pane.form_name.should == 'product_membership'
            pane.pane_id.should == "product_membership_#{membership.object_id}"
            pane.controller == 'product_membership'
            pane.foreign_key == nil
          end
        end
        # 何もしなければ何も出力されません
        @template.output_buffer.should == ""
      end

      it "when given object" do
        membership = ProductMembership.new
        @template.instance_variable_set(:@membership, membership)
        @template.nested_ajax_pane(:membership) do |pane|
          pane.parent.should == nil
          pane.object.should == membership
          pane.object_name.should == :membership
          pane.form.should == nil
          pane.form_name.should == :membership
          pane.pane_id.should == "membership_#{membership.object_id}"
          pane.controller == 'product_membership'
          pane.foreign_key == nil

          person = Person.new
          cascading_nested_ajax_pane = pane
          @template.nested_ajax_pane(person) do |cascading|
            pane.parent.should == nil
            pane.object.should == membership
            pane.object_name.should == :membership
            pane.form.should == nil
            pane.form_name.should == :membership
            pane.pane_id.should == "membership_#{membership.object_id}"
            pane.controller == 'product_membership'
            pane.foreign_key == nil
          end
        end
        # 何もしなければ何も出力されません
        @template.output_buffer.should == ""
      end
    end
  end
  
  describe "flash_message_for" do
    it "should be abled to use as template method" do
      @template.respond_to?(:nested_ajax_pane)
    end
    
    it "default" do
      flash[:notice] = "FLASH MESSAGE!"
      @template.flash_message_for(:notice).should == %{ 
        <p id="nested_ajax_flash_message_notice" style="color: green">FLASH MESSAGE!</p>
      }.split(/$/).map(&:strip).join
    end
    
    it "with options" do
      flash[:notice] = "FLASH MESSAGE!"
      @template.flash_message_for(:notice, :tag_name => :div, :class => 'flash_msg').should == %{ 
        <div class="flash_msg" id="nested_ajax_flash_message_notice">FLASH MESSAGE!</div>
      }.split(/$/).map(&:strip).join
    end
    
    it "2 keys specified" do
      flash[:notice] = "notice messages"
      flash[:error] = "error messages"
      @template.flash_message_for(:notice, :error).should == %{ 
        <p id="nested_ajax_flash_message_notice" style="color: green">notice messages</p>
        <p id="nested_ajax_flash_message_error" style="color: green">error messages</p>
      }.split(/$/).map(&:strip).join
    end
    
  end
  
  describe "ajax_flash_message_for" do
    it "should be abled to use as template method" do
      @template.respond_to?(:ajax_nested_ajax_pane)
    end
    
    it "should output js" do
      flash[:notice] = "notice messages"
      ajax_flash_message_for(:notice).split(/$/).map(&:strip).join.should == %{
       <script type="text/javascript">//<![CDATA[Element.update("nested_ajax_flash_message_notice", "notice messages");//]]></script>
      }.split(/$/).map(&:strip).join
    end
    
    describe "should output js with effect" do
      it "without params[:nested_ajax][:pane_id]" do
        flash[:notice] = "notice messages"
        ajax_flash_message_for(:notice, :effect => :highlight).split(/$/).map(&:strip).join.should == %{
         <script type="text/javascript">
         //<![CDATA[
         Element.update("nested_ajax_flash_message_notice", "notice messages");
         new Effect.Highlight("nested_ajax_flash_message_notice",{});
         //]]>
         </script>
        }.split(/$/).map(&:strip).join
      end

      describe "witho params[:nested_ajax][:pane_id]" do
        before(:each) do
          params[:nested_ajax] = {:pane_id => "pane_id_xxxx"}
        end

        it "output with effect for pane" do
          flash[:notice] = "notice messages"
          ajax_flash_message_for(:notice, :effect => :highlight).split(/$/).map(&:strip).join.should == %{
           <script type="text/javascript">
           //<![CDATA[
           Element.update("nested_ajax_flash_message_notice", "notice messages");
           new Effect.Highlight("nested_ajax_flash_message_notice",{});
           new Effect.Highlight(\"pane_id_xxxx\",{});
           //]]>
           </script>
          }.split(/$/).map(&:strip).join
        end
      end
    end
  end


end
