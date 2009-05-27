require 'nested_ajax'

ActionView::Base.class_eval do
  include NestedAjax::BaseHelper
  include NestedAjax::UtilityHelperMethods
end

ActionView::Helpers::FormBuilder.class_eval do
  include NestedAjax::FormBuilder
end
