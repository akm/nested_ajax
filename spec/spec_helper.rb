$KCODE='u'

unless Spec.const_defined?(:Rails)
  dir = File.dirname(__FILE__)
  require 'rubygems'
  require 'action_controller'
  
end

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'init')
