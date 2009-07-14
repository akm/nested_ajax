# -*- coding: utf-8 -*-
require "yaml/store"

class ActiveRecord::Reflection::AssociationReflection
  attr_accessor :accepts_allow_destroy
end

class ActiveRecord::Base
  class << self
    def accepts_nested_attributes_for_with_nested_ajax_generator(*attr_names, &block)
      original_attr_names = attr_names.dup
      options = { :allow_destroy => false }
      options.update(attr_names.extract_options!)
      result = accepts_nested_attributes_for_without_nested_ajax_generator(*original_attr_names, &block)
      if options[:allow_destroy]
        attr_names.each do |attr_name|
          self.reflections[attr_name.to_sym].accepts_allow_destroy = true
        end
      end
      result
    end
  end
  self.instance_eval do
    alias :accepts_nested_attributes_for_without_nested_ajax_generator :accepts_nested_attributes_for
    alias :accepts_nested_attributes_for :accepts_nested_attributes_for_with_nested_ajax_generator
  end
end


module Rails::Generator::Commands
  def self.map_resources_def(*resources)
    options = resources.extract_options!
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    result = "\n  map.resources #{resource_list}"
    result << ", " << options.inspect.gsub(/^\{|\}$/, '') unless options.empty?
    result << "\n"
  end
  
  class Create
    def file_include?(relative_destination, sentense)
      path = destination_path(relative_destination)
      content = File.read(path)
      content.include?(sentense)
    end
    
    def route_resources(*resources)
      map_resources_def = Rails::Generator::Commands.map_resources_def(*resources)
      sentinel = 'ActionController::Routing::Routes.draw do |map|'
      
      stripped = map_resources_def.strip
      if file_include?('config/routes.rb', stripped)
        logger.identical stripped
        return
      end
      
      logger.route map_resources_def.strip
      unless options[:pretend]
        gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}#{map_resources_def}"
        end
      end
    end  
  end

  class Destroy
    def route_resources(*resources)
      resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
      look_for = Rails::Generator::Commands.map_resources_def(*resources)
      logger.route "map.resources #{resource_list}"
      gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
    end
  end
end



class NestedAjaxScaffoldGenerator < Rails::Generator::NamedBase

  require File.join(File.dirname(__FILE__), '../base_attribute')

  class Attribute < BaseAttribute

    def initialize(generator, column, reflection = nil)
      super(column, reflection)
      @generator = generator
    end
    
    def field_type
      if belongs_to?
        return :belongs_to_field
      elsif selectable_attr_type == :single
        return :select
      elsif selectable_attr_type == :multi
        return :check_box_group
      end
      super
    end
    
    def input_type
      if belongs_to?
        return :input
      elsif selectable_attr_type == :single
        return :select
      elsif selectable_attr_type == :multi
        return :input
      end
      case field_type
      when :text_area then
        :textarea
      else
        :input
      end
    end
    
    def field
      if belongs_to?
        "belongs_to_field :#{@reflection.name.to_s}, :controller => '#{@generator.model_to_controller(@reflection.class_name)}'"
      else
        "#{field_type} :#{name}"
      end
    end
  end
  
  default_options :generate_action_views => false, :add_timestamps => false
  
  attr_reader   :model_class,
                :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :controller_file_name,
                :controller_resource_name_singularized,
                :controller_resource_name,
                :controller_base_url,
                :controller_name_raw,
                :controller_category_name,
                :controller_reflections,
                :one_to_many_reflections,
                :attrs_expression_for_test,
                :default_file_extension
  
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super(runtime_args, runtime_options)
    begin
      @default_file_extension = "html.erb"
      @model_class = class_name.constantize
      @controller_name_raw = @controller_name = @args.pop || @name.underscore.pluralize
      puts "options: #{options.inspect}"
      if @controller_category_name = options[:category]
        @controller_name = [@controller_category_name, @controller_name].compact.join("/")
      end
      save_model_to_controller(@model_class.name)


      base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
      @controller_class_name_without_nesting, @controller_file_name, @controller_plural_name = inflect_names(base_name)
      @controller_singular_name = @controller_file_name.singularize
      @controller_plural_name = @controller_file_name.singularize.pluralize # people -> peoples 対策

      @controller_class_name = @controller_class_nesting.empty? ?
        @controller_class_name_without_nesting :
        "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"

      path_parts = @controller_file_path.split('/')
      path_parts = path_parts[0..-2].map{|name| name.singularize} << path_parts[-1]
      @controller_resource_name = path_parts.join('_')
      @controller_resource_name_singularized = @controller_resource_name.singularize

      @controller_base_url = @controller_category_name ?
        [controller_category_name, @controller_name_raw].compact.join('/') :
        @controller_resource_name

      @controller_reflections = @model_class.reflections
      @one_to_many_reflections = @controller_reflections.values.select do |reflection|
        (reflection.macro == :has_many) && # :has_and_belongs_to_many はひとまずサポート外
          @model_class.instance_methods.include?("#{reflection.name}_attributes=")
      end
      (@controller_reflections.values - @one_to_many_reflections).each do |reflection|
        puts "INFO #{reflection.macro} :#{reflection.name} is ignored in view because #{@model_class.name} doesn't have accepts_nested_attributes_for(:#{reflection.name})"
      end


      except_col_names = ['id']
      columns = @model_class.columns.select{|col| !except_col_names.include?(col.name) }
      columns = columns.select{|col| !%w(created_at updated_at).include?(col.name)} unless options[:add_timestamps]

      column_to_reflection = {}
      @controller_reflections.each do |name, reflection|
        column_to_reflection[reflection.primary_key_name.to_s] = reflection
      end

      ignore_selectable_attr = options[:ignore_selectable_attr] || !(Module.const_get(:SelectableAttr) rescue nil)
      @attributes = columns.map do |column| 
        attr = Attribute.new(self, column, column_to_reflection[column.name.to_s])
        unless ignore_selectable_attr
          attr.selectable_attr_type = @model_class.selectable_attr_type_for(column.name.to_s)
          if attr.selectable_attr_type
            attr.selectable_attr_base_name = @model_class.enum_base_name(column.name.to_s)
            attr.selectable_attr_enum = @model_class.enum_for(column.name.to_s)
          end
        end
        attr
      end

      @attrs_expression_for_test = test_attrs_expression(@attributes)

    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n  ")
      raise e
    end
  end
  
  def save_model_to_controller(model_name, category = controller_category_name, controller = controller_name)
    db = YAML::Store.new(File.join(RAILS_ROOT, 'config/nested_ajax.yml'))
    db.transaction do
      db[category || 'default'] ||= {}
      old_value = db[category || 'default'][model_name]
      if !old_value.blank? && (old_value != controller)
        puts "WARNING!! controller name for #{model_name} is changed from #{old_value} to #{controller}"
      end
      db[category || 'default'][model_name] = controller
    end
  end

  def model_to_controller(model_name)
    db = YAML::Store.new(File.join(RAILS_ROOT, 'config/nested_ajax.yml'))
    db.transaction(true) do # readonly = true
      [controller_category_name, 'default'].compact.each do |categ|
        if map = db[categ]
          if controller = map[model_name]
            return controller
          end
        end
      end
    end
    result = [controller_category_name, model_name.underscore.pluralize].compact.join('/')
    save_model_to_controller(model_name, controller_category_name, result)
    result
  end

  def test_attrs_expression(attributes)
    test_attr_names = nil
    begin
      record = @model_class.new({})
      record.valid?
      test_attr_names = record.errors.map{|attr, msg| attr.to_s}
    rescue
      test_attr_names = attributes.map{|attr|attr.name.to_s}
    end
    attributes_hash = Hash[*attributes.map{|a|[a.name.to_s, a]}.flatten]
    result = []
    test_attr_names.each do |attr_name|
      attr = attributes_hash[attr_name]
      result << ':%s => %s' % [attr_name, attr.default_value]
    end
    '{%s}' % result.join(', ')
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("\n  ")
    raise e
  end
  
  def manifest
    recorded_session = record do |m|
      begin
        m.directory('public/stylesheets')
        m.template('nested_ajax.css', 'public/stylesheets/nested_ajax.css')

        m.directory(File.join('app/controllers', controller_class_path))
        m.directory(File.join('app/helpers', controller_class_path))
        m.directory(File.join('app/views', controller_class_path, controller_file_name))
        m.directory(File.join('app/views/layouts', controller_class_path))
        m.directory(File.join('spec/routing', controller_class_path))
        m.directory(File.join('spec/controllers', controller_class_path))
        m.directory(File.join('spec/helpers', controller_class_path))
        m.directory(File.join('spec/views', controller_class_path, controller_file_name))
        
        m.template('controller.rb', 
          File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb"))

        m.template('controller_spec.rb',
          File.join('spec/controllers', controller_class_path, "#{controller_file_name}_controller_spec.rb"))

        m.template('routing_spec.rb',
          File.join('spec/routing', controller_class_path, "#{controller_file_name}_routing_spec.rb"))

        m.template("layout.html.erb",
          File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))

        m.template 'helper_spec.rb',
          File.join('spec/helpers', controller_class_path, "#{controller_file_name}_helper_spec.rb")

        m.template "helper.rb",
          File.join('app/helpers', controller_class_path, "#{controller_file_name}_helper.rb")

        SCAFFOLD_VIEWS.each do |view|
          m.template("view_#{view}.html.erb",
            File.join('app/views', controller_class_path, controller_file_name, "#{view}.html.erb"))
        end

        SCAFFOLD_PARTIALS.each do |view|
          m.template("partial_#{view}.html.erb",
            File.join('app/views', controller_class_path, controller_file_name, "_#{view}.html.erb"))
        end

        m.template "edit_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "edit.#{default_file_extension}_spec.rb")
        m.template "index_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "index.#{default_file_extension}_spec.rb")
        m.template "new_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "new.#{default_file_extension}_spec.rb")
        m.template "show_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "show.#{default_file_extension}_spec.rb")

        m.file("nested_ajax_indicator.gif", 'public/images/nested_ajax_indicator.gif')

        if controller_category_name
          m.route_resources(
            controller_name_raw.gsub(/\//, '_'), 
            :path_prefix => controller_category_name,
            :name_prefix => controller_category_name.gsub(/\//, '_') + '_',
            :controller => controller_name,
            :collection => {:names => :get}
            )
        elsif controller_class_nesting_depth > 0
          m.route_resources(
            controller_resource_name,
            :controller => controller_name,
            :collection => {:names => :get}
            )
        else
          m.route_resources(
            controller_resource_name,
            :collection => {:names => :get})
        end

      rescue Exception => e
        puts e.message
        puts e.backtrace.join("\n  ")
        raise e
      end
    end
  end
  
  protected
  
  SCAFFOLD_VIEWS = %w(index show new edit)
  SCAFFOLD_PARTIALS = %w(form)

  def banner
    "Usage: #{$0} nested_ajax_scaffold ModelName [ControllerName]"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on('--category=[cateogry name]',
      "Category name is used as path_prefix and name_prefix in config/routes.rb, and used also as name space for model/controller mapping") { |v| 
      options[:category] = v }
    opt.on("--add-timestamps",
      "Add timestamps to the view files for this model") { |v| options[:add_timestamps] = v }
    opt.on("--ignore-selectable-attr",
      "Don't generate field for selectable_attr plugin") { |v| options[:ignore_selectable_attr] = v }
  end

end
