# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../spec_helper')

describe NestedAjax::UtilityHelperMethods do
  
  include NestedAjax::UtilityHelperMethods

  describe "join_line_with" do
    describe "should insert separator between tags" do
      it "basically" do
        should_receive(:capture).once.and_return(<<-EOS)
          <a href="/foo">FOO</a>
          <a href="/bar">BAR</a>
          <a href="/baz">BAZ</a>
        EOS
        expected = [
          '<a href="/foo">FOO</a> |',
          '<a href="/bar">BAR</a> |',
          '<a href="/baz">BAZ</a>'
          ].join("\n")
        should_receive(:concat).with(expected).once
        join_line_with{ "dummy" }
      end

      it "with blank lines" do
        should_receive(:capture).once.and_return(<<-EOS)


          <a href="/foo">FOO</a>


          <a href="/bar">BAR</a>


          <a href="/baz">BAZ</a>


        EOS
        expected = [
          '<a href="/foo">FOO</a> |',
          '<a href="/bar">BAR</a> |',
          '<a href="/baz">BAZ</a>'
          ].join("\n")
        should_receive(:concat).with(expected).once
        join_line_with{ "dummy" }
      end
    end
  end

  
end
