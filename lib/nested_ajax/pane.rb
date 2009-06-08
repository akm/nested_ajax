require 'nested_ajax'

module NestedAjax
  module Pane

    autoload :AbstractPane, 'nested_ajax/pane/abstract_pane'
    autoload :SinglePane, 'nested_ajax/pane/single_pane'
    autoload :AssociationPane, 'nested_ajax/pane/association_pane'
    autoload :HasManyPane, 'nested_ajax/pane/has_many_pane'
    autoload :BelongsToPane, 'nested_ajax/pane/belongs_to_pane'

    autoload :DummyPane, 'nested_ajax/pane/dummy_pane'
  end
end
