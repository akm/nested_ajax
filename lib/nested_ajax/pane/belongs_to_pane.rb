require 'nested_ajax/pane'

module NestedAjax
  module Pane
    class BelongsToPane < AssociationPane
      def initialize(template, form_or_object, association_name, options = {})
        super(template, form_or_object, association_name, options)
        unless @reflection.macro == :belongs_to
          raise ArgumentError, "#{association_name} of #{object.class.name} is not defined with belongs_to but #{@reflection.macro}"
        end
      end
      
      def link_to_new(link_name, options = {}, html_options = {})
        html_options[:id] ||= "#{id}_#{association_name}_new"
        link_id = html_options[:id]
        options = {
          :method => :get,
          :update => link_id,
          :position => :after,
          :object_name => controller.to_s.singularize,
          :url => new_url
        }.update(self.options[:link_to_new] || {}).update(options || {})
        base_script = remote_function(options)
        link_to(link_name, 'javascript:void(0)', html_options) <<
          javascript_tag(%{
            (function(){
              Event.observe("#{link_id}", "click", function(event){
                #{options[:onclick]};
                #{base_script};
                Event.stop(event);
              }, true);
            })();
          }.split(/$/).map(&:strip).join)
      end

      def new_url
        nested_ajax = {
          :in_form => !form.nil?
        }
        nested_ajax[:pane_id] = pane_id
        if form
          nested_ajax[:form_name] = base_form_name
        end
        result = {:controller => controller, :action => :new, :nested_ajax => nested_ajax}
        yield(result) if block_given?
        result
      end
      

    end
  end
end
