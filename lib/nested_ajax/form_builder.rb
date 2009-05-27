module NestedAjax
  module FormBuilder
    attr_accessor :pane

    pane_forwarding_methods = [
      :pane_id,
      :has_many,
      :submittable?, 
      :xhr?, :in_form?, :foreign_key?, :foreign_key, :link_to_new_cancel
    ]

    pane_forwarding_methods.each do |forwarding_method|
      class_eval(<<-EOS)
        def #{forwarding_method}(*args, &block)
          raise NestedAjax::UsageError, "This form has no pane. You may use form_for instead of pane.form_for" unless pane
          pane.#{forwarding_method}(*args, &block)
        end
      EOS
    end

  end

end
