$KCODE='u'

ENV['RAILS_ENV'] ||= 'test'
unless defined?(RAILS_ENV)
  RAILS_ENV = 'test' 
  RAILS_ROOT = File.dirname(__FILE__) unless defined?(RAILS_ROOT)

  require 'rubygems'
  require 'spec'

  require 'active_support'
  require 'active_record'
  # require 'action_mailer'
  require 'action_controller'
  require 'action_view'
  require 'initializer'

  $LOAD_PATH.unshift File.join(File.dirname(__FILE__), "resources/controllers")
  require 'application_controller.rb'

  ActionController::Routing::Routes.draw do |map|
    map.connect ':controller/:action/:id.:format'
    map.connect ':controller/:action/:id'
  end

  require 'spec/autorun'
  require 'spec/rails'

  $LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
  require File.join(File.dirname(__FILE__), '..', 'init')
end
