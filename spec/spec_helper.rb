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

  require 'yaml'
  config = YAML.load(IO.read(File.join(File.dirname(__FILE__), 'database.yml')))
  ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))
  ActionController::Base.logger = ActiveRecord::Base.logger
  ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])


  load(File.join(File.dirname(__FILE__), 'schema.rb'))

  %w(resources/models resources/controllers).each do |path|
    $LOAD_PATH.unshift File.join(File.dirname(__FILE__), path)
    ActiveSupport::Dependencies.load_paths << File.join(File.dirname(__FILE__), path)
  end
  Dir.glob("resources/**/*.rb") do |filename|
    require filename
  end
  

  ActionController::Routing::Routes.draw do |map|
    map.connect ':controller/:action/:id.:format'
    map.connect ':controller/:action/:id'
  end

  require 'spec/autorun'
  require 'spec/rails'

  $LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
  require File.join(File.dirname(__FILE__), '..', 'init')
end
