# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../spec_helper')

class MockController < ActionController::Base
  include NestedAjax::RenderExt
end

class MockTemplate
  include ActionView::Helpers
end



describe NestedAjax::RenderExt, :type => :view do

  before(:each) do
    request  = ActionController::TestRequest.new
    response = ActionController::TestResponse.new
    response.request = request
    response.template = MockTemplate.new
    @controller = MockController.new
    @controller.stub!(:request).and_return(request)
    @controller.stub!(:response).and_return(response)
  end

  describe "auto_complete_html" do
    it "default" do
      result = @controller.send(:auto_complete_html, [['foo', 1], ['bar', 2], ['baz', 3]]).should == 
        '<ul><li>foo<span style="display:none;">1</span></li><li>bar<span style="display:none;">2</span></li><li>baz<span style="display:none;">3</span></li></ul>'
    end
  end
end

# :type が違うので上のと分けています。
describe NestedAjax::RenderExt do

  before(:each) do
    request  = ActionController::TestRequest.new
    response = ActionController::TestResponse.new
    response.request = request
    response.template = MockTemplate.new
    @controller = MockController.new
    @controller.stub!(:request).and_return(request)
    @controller.stub!(:response).and_return(response)
  end

  describe "render_if_xhr" do
    it "should render if xhr?" do
      @controller.request.should_receive(:xhr?).twice.and_return(true)
      @controller.should_receive(:render).with("render arguments")
      @controller.send(:render_if_xhr, "render arguments")
    end

    it "should render unless xhr?" do
      @controller.request.should_receive(:xhr?).twice.and_return(false)
      @controller.should_not_receive(:render).with("render arguments")
      @controller.send(:render_if_xhr, "render arguments")
    end

  end

  describe "render" do
    it "for xhr without layout" do
      @controller.request.should_receive(:xhr?).once.and_return(true)
      @controller.should_receive(:flash).and_return(mock("flash", :discard => true))
      # find_templateメソッドはファイルが見つからなかった場合には例外を返します。
      mock_view_paths = stub("view_paths")
      class << mock_view_paths
        def find_template(*args)
          raise ActionView::MissingTemplate.new(["layouts/nested_ajax"], "not found")
        end
      end
#       mock_view_paths.should_receive(:find_template).
#         with("layouts/nested_ajax", 'html').
#         and_raise(ActionView::MissingTemplate.new(["layouts/nested_ajax"], "not found"))
      @controller.should_receive(:view_paths).and_return(mock_view_paths)
      @controller.should_receive(:default_template_format).and_return("html")
      @controller.should_receive(:render_without_nested_ajax).
        with({:action => "show", :layout => false}, {})
      @controller.send(:render, :action => "show")
    end
    
    it "for xhr with default layout" do
      @controller.request.should_receive(:xhr?).once.and_return(true)
      @controller.should_receive(:flash).and_return(mock("flash", :discard => true))
      @controller.should_receive(:view_paths).and_return(mock("view_paths", :find_template => "nested_ajax"))
      @controller.should_receive(:default_template_format).and_return(nil)
      @controller.should_receive(:render_without_nested_ajax).
        with({:action => "show", :layout=>"nested_ajax"}, {})
      @controller.send(:render, :action => "show")
    end
    
    it "for xhr with specified layout" do
      MockController.ajax_layout("special_layout")
      @controller.request.should_receive(:xhr?).once.and_return(true)
      @controller.should_receive(:flash).and_return(mock("flash", :discard => true))
      @controller.should_receive(:render_without_nested_ajax).
        with({:action => "show", :layout=>"special_layout"}, {})
      @controller.send(:render, :action => "show")
    end
    
    it "for normal request" do
      @controller.request.should_receive(:xhr?).once.and_return(false)
      @controller.should_not_receive(:flash)
      @controller.should_not_receive(:view_paths)
      @controller.should_not_receive(:default_template_format)
      @controller.should_receive(:render_without_nested_ajax).with({:action => "show"}, {})
      @controller.send(:render, :action => "show")
    end
  end
  
  
end
