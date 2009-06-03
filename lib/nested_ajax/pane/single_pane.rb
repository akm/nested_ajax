require 'nested_ajax/pane'

module NestedAjax
  module Pane
    class SinglePane < AbstractPane

      def belongs_to(association_name, options = {})
        if form
          form.fields_for(association_name, form.object) do |f|
            pane = Pane::BelongsToPane.new(template, f, association_name,
              {:pane_id => "#{self.pane_id}_#{association_name}"}.update(options || {}))
            pane.parent = self
            yield(pane)
          end
        else
          raise "Unsupported yet"
        end
      end

      def has_many(association_name, options = {})
        pane = Pane::HasManyPane.new(template, object, association_name, options)
        pane.parent = self
        yield(pane)
      end

      def link_to_new_cancel(name, options = nil)
        link_to_function(name, "Element.remove('#{self.id}')", options)
      end

      def link_to_show(name, options = nil)
        link_to_remote(name, {
            :update => pane_id, 
            :method => :get,
            :url => build_url(:show),
          }, options)
      end
      alias_method :link_to_edit_cancel, :link_to_show

      def link_to_edit(name, options = nil)
        link_to_remote(name, {
            :update => pane_id,
            :method => :get,
            :url => build_url(:edit),
          }, options)
      end

      def link_to_destroy(name, options = {})
        effect = options[:effect]
        link_to_remote(name, {
            :update => pane_id,
            :method => :delete,
            :url => build_url(:destroy),
            :success => effect
          }, options)
      end
      
      def build_url(action)
        nested_ajax = { 
          :foreign_key => association_foreign_key || foreign_key,
          :in_form => !form.nil?,
          :pane_id => pane_id,
          :form_name => base_form_name
        }
        result = {:controller => controller, :action => action, :id => object.id, :nested_ajax => nested_ajax}
        yield(result) if block_given?
        result
      end
      
    end
  end
end
