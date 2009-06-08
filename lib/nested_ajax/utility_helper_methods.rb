require 'nested_ajax'

module NestedAjax
  module UtilityHelperMethods
    def join_line_with(separator = " |\n", &block)
      text = capture(&block)
      tag_content = '[^<>]+?'
      text.gsub!(/<\/(#{tag_content})>[\n\s]+?<(#{tag_content})>/m) do
        "</#{$1}>#{separator}<#{$2}>"
      end
      concat(text.strip)
    end
  end
end
