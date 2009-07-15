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

    def tag_for_object(obj, options = nil, &block)
      options = {
        :tag_name => :div,
        :id => "#{obj.class.name.underscore.gsub(/\//, '_')}_#{obj.object_id}"
      }.update(options || {})
      
      tag_name = options.delete(:tag_name)
      id = options[:id]
      result = content_tag(tag_name, options) do
        capture(id, &block)
      end
      concat(result)
    end
  end
end
