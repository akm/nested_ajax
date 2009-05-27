# -*- coding: utf-8 -*-
require 'nested_ajax/pane'
require 'forwardable'

module NestedAjax
  module Pane
    class AbstractPane
      extend Forwardable

      attr_accessor :controller
      attr_accessor :parent, :association_foreign_key
      attr_reader :template, :form, :id, :options
      attr_reader :object, :object_name
      attr_reader :pane_id
      alias_method :id, :pane_id

      def initialize(template, form_or_object, options = {})
        @template = template
        if form_or_object.respond_to?(:fields_for)
          @form = form_or_object
          @object = @form.object
        else
          @form = nil
          @object = form_or_object
        end
        @object_name = options[:object_name] || @object.class.name.underscore
        @controller = options[:controller]
        @foreign_key = options[:foreign_key]
        @pane_id ||= (options[:pane_id] || nested_ajax_options[:pane_id] || "#{object_name}_#{object.object_id}")
        @options = options || {}
      end
      
      def_instance_delegators(:@template, 
        :logger, :request, :params, 
        :concat, :capture, :tag,
        :remote_form_for,
        :form_for, :fields_for, :hidden_field_tag,
        :remote_function, :link_to, :link_to_function, :link_to_remote, :url_for, 
        :javascript_tag)

      def process(&block)
        with_instance_variable(object_name, object) do
          yield(self) if block_given?
        end
      end
      
      def process_with_tag(options = {}, &block)
        PaneTag.render(template, self.id, options) do
          process(&block)
        end
      end

      def with_instance_variable(name, new_value)
        instance_var_name = '@%s' % name
        backup = @template.instance_variable_get(instance_var_name)
        begin
          @template.instance_variable_set(instance_var_name, new_value)
          yield(new_value)
        ensure
          @template.instance_variable_set(instance_var_name, backup)
        end
      end

      # このメソッドで用意したpaneを NestedAjax::BaseHelper.nested_ajax_pane では
      # 使用してオブジェクトを改めて作らないようにしています。
      def render(options = {}, local_assigns = nil, &block)
        locals = nil
        case options
        when Hash
          locals = (options[:locals] ||= {})
        else
          locals = local_assigns || {}
        end
        locals.update({:cascading_nested_ajax_pane => self})
        @template.render(options, local_assigns, &block)
      end

      def base_form_name
        @base_form_name ||= object_name
      end
      
      def nested_ajax_options
        @template.nested_ajax_options
      end

      def submittable?
        xhr? ? !in_form? : true
      end

      def xhr?
        request.xhr?
      end

      def in_form?
        nested_ajax_options[:in_form] == "true"
      end

      def foreign_key?(attr)
        attr.to_s == foreign_key
      end

      def foreign_key
        @foreign_key ||= nested_ajax_options[:foreign_key]
      end

      def root?
        request.xhr? ? false : (!params[:nested_ajax] && !parent)
      end

      def form_for(*args, &block)
        pane_setter = lambda do |f|
          f.pane = self
          concat(capture(f, &block))
        end
        if params[:nested_ajax]
          form_or_fields_for(*args, &pane_setter)
        else
          @template.form_for(*args, &pane_setter)
        end
      end

      private

      def form_or_fields_for(*args, &block)
        if in_form?
          fields_for_nested_ajax(*args, &block)
        else
          form_for_nested_ajax(*args, &block)
        end
      end

      def fields_for_nested_ajax(*args, &block)
        PaneTag.render(@template, pane_id, options[:html]) do
          fields_for(*args, &block)
        end
      end

      def form_for_nested_ajax(*args, &block)
        options = args.extract_options!
        tag_name, html_options = PaneTag.name_and_options(pane_id, options[:html])
        form_options = {
          :update => pane_id,
        }
        html_options = html_options.update(options[:html] || {})
        PaneTag.render(@template, pane_id, options[:html]) do
          remote_form_for(*(args + [form_options])) do |f|
            nested_ajax_options.each do |key, value|
              concat(hidden_field_tag(:"nested_ajax[#{key}]", value))
            end
            concat(capture(f, &block))
          end
        end
      end


      private

      def place_holder(name)
        "**#{name.to_s}**"
      end

      def escaped_place_holder(name)
        CGI.escape(place_holder(name))
      end

    end
  end
end
