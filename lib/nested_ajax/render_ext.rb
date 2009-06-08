require 'nested_ajax'

module NestedAjax
  module RenderExt
    def self.included(mod)
      mod.module_eval do
        alias_method_chain :render, :nested_ajax
      end
    end

    private

    def auto_complete_html(name_and_ids, options = {})
      options = {
        :outer_tag => :ul,
        :inner_tag => :li,
      }.update(options || {})
      outer_tag = options[:outer_tag]
      inner_tag = options[:inner_tag]
      outer_tag = [outer_tag, {}] unless outer_tag.is_a?(Array)
      inner_tag = [inner_tag, {}] unless inner_tag.is_a?(Array)
      timestamp = Time.now.to_i
      response.template.content_tag(outer_tag.first, 
        name_and_ids.map do |(name, id)|
          response.template.content_tag(inner_tag.first, 
            response.template.sanitize(name) + 
            response.template.content_tag(:span, 
              response.template.sanitize(id.to_s), 
              :id => "#{timestamp}_record_#{id}_value", :style => 'display:none;'),
            {:id => "#{timestamp}_record_#{id}"}.update(inner_tag.last))
        end.join,
        outer_tag.last)
    end


    def render_if_xhr(*args, &block)
      render(*args, &block) if request.xhr?
      request.xhr?
    end

    protected

    DEFAULT_NESTED_AJAX_LAYOUT = 'nested_ajax'
    
    def render_with_nested_ajax(options = nil, extra_options = {}, &block)
      if request.xhr? 
        flash.discard
        if (options.nil? || options.is_a?(Hash))
          layout = self.class.read_inheritable_attribute(:ajax_layout)
          begin
            layout ||= view_paths.find_template("layouts/#{DEFAULT_NESTED_AJAX_LAYOUT}", default_template_format)
          rescue ActionView::MissingTemplate
          end
          layout ||= false
          options ||= {}
          options[:layout] = layout
        end
      end
      render_without_nested_ajax(options, extra_options, &block)
    end

    module ClassMethod
      def ajax_layout(template_name)
        write_inheritable_attribute(:ajax_layout, template_name)
      end
    end

  end
end
