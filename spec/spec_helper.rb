$KCODE='u'

unless Spec.const_defined?(:Rails)
  dir = File.dirname(__FILE__)
  require 'rubygems'
  require 'active_support'
  require 'active_record'
  require 'action_controller'
  require 'action_view'
  
  require 'spec/autorun'
  # require 'spec/rails'

end

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'init')
