require 'nested_ajax/form_builder'

module NestedAjax
  module FormBuilder
    module TagForObject
      def tag(options = nil, &block)
        @template.tag_for_object(object, options, &block)
      end
    end
  end
end
