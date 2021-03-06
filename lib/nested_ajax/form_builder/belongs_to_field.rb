# -*- coding: utf-8 -*-
require 'nested_ajax/form_builder'

module NestedAjax
  module FormBuilder
    module BelongsToField
      
      def belongs_to_field(association_name, options = {}, &block)
        reflection = object.class.reflections[association_name.to_sym]
        raise ArgumentError, "association not found - #{association_name}" unless reflection
        unless reflection.macro == :belongs_to
          raise ArgumentError, "#{association_name} of #{object.class.name} is not defined with belongs_to but #{reflection.macro}"
        end
        url = @template.url_for(options[:url] || {:controller => options[:controller], :action => options[:action] || 'names'})
        base_id = "#{object.class.name}_#{object.object_id}_#{association_name}"
        reflection_name = nil
        if object
          if reflection_obj = object.send(association_name)
            if reflection_obj.respond_to?(:name_for_nested_ajax)
              reflection_name = reflection_obj.name_for_nested_ajax
            end
            reflection_name ||= reflection_obj.inspect
          end
        end
        foreign_key_name = reflection.association_foreign_key
        result = "\n"
        result << "\n" << @template.tag(:input, :type => :text, :id => "#{base_id}_display", :value => reflection_name)
        result << "\n" << @template.content_tag(:div, '', :id => "#{base_id}_results", :class => 'auto_complete')
        # hiddenにしたいんだけど、hiddenだとdisabledが効かないようなので、敢えて普通のtype="text"を指定した上で非表示にしています。
        result << "\n" << text_field(foreign_key_name, :id => "#{base_id}_fk", :style => 'display:none;')
        auto_complete_options = {
          :method => 'get',
          :paramName => options[:param_name] || 'name',
          :tokens => (options[:tokens] || []).to_json,
          :frequency => options[:frequency] || 0.4,
          :minChars => options[:min_chars] || 1,
          :indicator => options[:indicator] || "#{base_id}_indicator",
          :defaultParams => options[:default_params],
          :callback => options[:build_parameter],
          :afterUpdateElement => options[:after_update_element],
        }
        unless options[:indicator]
          result << "\n" << @template.tag(:img, :id => "#{base_id}_indicator", :src => '/images/nested_ajax_indicator.gif', :style => 'display:none;')
        end
        update_element_function = %{
          function(selected){
            $("#{base_id}_display").value = selected.firstChild.nodeValue;
            $("#{base_id}_fk").value = selected.lastChild.innerHTML.stripTags();
          }
        }.split(/$/).map(&:strip).join
        auto_complete_options = auto_complete_options.to_json.gsub(/\}$/, ", updateElement: #{update_element_function}}")
        result << "\n" << @template.javascript_tag(%{
          new Ajax.Autocompleter('#{base_id}_display', '#{base_id}_results', '#{url}',
            #{auto_complete_options})
          }.split(/$/).map(&:strip).join)

        if block_given?
          @template.concat(result)
          on_click_link_to_new = %{
            $("#{base_id}_display").disable();
            $("#{base_id}_fk").disable();
          }.split(/$/).map(&:strip).join
          belongs_to_pane_options = {:link_to_new => {:success => on_click_link_to_new} }.update(options || {})
          self.pane.belongs_to(association_name, belongs_to_pane_options, &block)
        end

        result
      end

    end
  end
end
