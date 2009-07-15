# -*- coding: utf-8 -*-
require 'nested_ajax/form_builder'

module NestedAjax
  module FormBuilder
    module MarkForDestruction
      
      def link_to_mark_for_destruction(name, options = {})
        result = hidden_field(:_delete, :autocomplete => 'off',
          :value => self.object.marked_for_destruction? ? '1' : '0')
        hidden_id = result.scan(/id\=\"(.+?)\"/).flatten.first
        action = "$('#{hidden_id}').value = '1';"
        action << options.delete(:effect) if options[:effect]
        result << @template.link_to_function(name, action, options)
        result
      end

    end
  end
end
