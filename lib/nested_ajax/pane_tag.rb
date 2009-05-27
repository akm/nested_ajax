module NestedAjax
  module PaneTag

    class << self

      def name_and_options(pane_id, options = nil)
        options ||= {}
        html_options = HashWithIndifferentAccess.new(
          {:tag_name => :div, :id => pane_id}.update(options))
        html_options[:class] = 'nested_ajax ' << (html_options[:class] || '')
        tag_name = html_options.delete(:tag_name)
        return tag_name, html_options
      end

      def render(template, pane_id, options)
        tag_name, options = name_and_options(pane_id, options)
        template.concat(template.tag(tag_name, options, true))
        yield if block_given?
        template.concat("</#{tag_name}>")
      end

    end

  end
end
