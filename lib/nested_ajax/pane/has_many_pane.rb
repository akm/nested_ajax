require 'nested_ajax/pane'

module NestedAjax
  module Pane
    class HasManyPane < AssociationPane
      attr_accessor :child_index

      def initialize(template, form_or_object, association_name, options = {})
        super(template, form_or_object, association_name, options)
        logger.debug("HasManyPane.initialize @form_name => #{@form_name}")
        unless @reflection.macro == :has_many
          raise ArgumentError, "#{association_name} of #{object.class.name} is not defined with belongs_to but #{@reflection.macro}"
        end
        @child_index = options[:child_index] || @associated_object.size
      end
      
      def each(options = nil, &block)
        @associated_object.each do |associated|
          object_name = associated.class.name.underscore
          options = {
            :object_name => object_name
          }.update(options || {})
          pane_options = {
            :object_name => options.delete(:object_name),
            :controller => options.delete(:controller) || self.controller,
            :foreign_key => association_foreign_key
          }
          sub_pane = SinglePane.new(template, associated, pane_options)
          sub_pane.parent = self
          sub_pane.process_with_tag(options, &block)
          @child_index += 1
        end
      end


      def link_to_new(link_name, options = {}, html_options = {})
        html_options[:id] ||= "#{id}_#{association_name}_new"
        link_id = html_options[:id]
        options = {
          :method => :get,
          :update => link_id,
          :position => :before,
          :object_name => controller.to_s.singularize,
          :url => new_url do |parameters|
            if object.respond_to?(:new_record?) && !object.new_record?
              parameters[:"#{@reflection.class_name.underscore}[#{association_foreign_key}]"] = object.id
            end
          end
        }.update(options || {})
        base_script = remote_function(options)
        link_to(link_name, 'javascript:void(0)', html_options) <<
          javascript_tag(%{
            (function(){
              var base_script = "#{base_script}";
              var child_index = #{@child_index};
              var child_index_holder = new RegExp(RegExp.escape("#{escaped_place_holder(:child_index)}"));
              Event.observe("#{link_id}", "click", function(event){
                var script = base_script.gsub(child_index_holder, child_index);
                eval(script);
                child_index++;
                Event.stop(event);
              }, true);
            })();
          }.split(/$/).map(&:strip).join)
      end

      def new_url
        nested_ajax = {
          :foreign_key => association_foreign_key,
          :in_form => in_form?,
          :form_name => form_name
        }
        nested_ajax[:pane_id] = pane_id + '_' << place_holder(:child_index)
        result = {:controller => controller, :action => :new, :nested_ajax => nested_ajax}
        yield(result) if block_given?
        result
      end
      
      def form_name
        unless @form_name
          @form_name = form_name_with_parent
          @form_name << "[#{place_holder(:child_index)}]"
          logger.debug("HasManyPane.form_name @form_name => #{@form_name}")
        end
        @form_name
      end

    end
  end
end
