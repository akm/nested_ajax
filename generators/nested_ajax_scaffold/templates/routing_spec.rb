require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * controller_class_nesting_depth %>/../spec_helper')

describe <%= controller_class_name %>Controller do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "<%= controller_name %>", :action => "index").should == "/<%= controller_base_url %>"
    end
  
    it "maps #new" do
      route_for(:controller => "<%= controller_name %>", :action => "new").should == "/<%= controller_base_url %>/new"
    end
  
    it "maps #show" do
      route_for(:controller => "<%= controller_name %>", :action => "show", :id => "1").should == "/<%= controller_base_url %>/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "<%= controller_name %>", :action => "edit", :id => "1").should == "/<%= controller_base_url %>/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "<%= controller_name %>", :action => "create").should == {:path => "/<%= controller_base_url %>", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "<%= controller_name %>", :action => "update", :id => "1").should == {:path =>"/<%= controller_base_url %>/1", :method => :put}
    end
  
    it "maps #destroy" do
      route_for(:controller => "<%= controller_name %>", :action => "destroy", :id => "1").should == {:path =>"/<%= controller_base_url %>/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/<%= controller_base_url %>").should == {:controller => "<%= controller_name %>", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/<%= controller_base_url %>/new").should == {:controller => "<%= controller_name %>", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/<%= controller_base_url %>").should == {:controller => "<%= controller_name %>", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/<%= controller_base_url %>/1").should == {:controller => "<%= controller_name %>", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/<%= controller_base_url %>/1/edit").should == {:controller => "<%= controller_name %>", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/<%= controller_base_url %>/1").should == {:controller => "<%= controller_name %>", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/<%= controller_base_url %>/1").should == {:controller => "<%= controller_name %>", :action => "destroy", :id => "1"}
    end
  end
end
