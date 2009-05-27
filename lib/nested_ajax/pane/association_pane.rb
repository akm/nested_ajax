require 'nested_ajax/pane'

module NestedAjax
  module Pane
    class AssociationPane < AbstractPane
      attr_accessor :association_name

      def initialize(template, form_or_object, association_name, options = {})
        super(template, form_or_object, options)
        @association_name = association_name
        @associated_object = @object.send(@association_name)
        @controller ||= @association_name
      end
      
      def pane_id
        @pane_id ||= (options[:pane_id] || "#{object_name}_#{object.object_id}_#{association_name}")
      end

      def base_form_name
        @base_form_name ||= "#{object_name}[#{association_name}_attributes]"
      end

      # 
      def association_foreign_key
        object.class.reflections[association_name.to_sym].primary_key_name
      end

      
    end
  end
end
