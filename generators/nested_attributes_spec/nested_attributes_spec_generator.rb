# -*- coding: utf-8 -*-

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

class NestedAttributesSpecGenerator < Rails::Generator::NamedBase

  require File.join(File.dirname(__FILE__), '../base_attribute')

  class Attribute < BaseAttribute
    def initialize(generator, column, reflection = nil)
      super(column, reflection)
      @generator = generator
    end

    def default_value(index = nil, for_view = false)
      result = super(for_view)
      return result if selectable_attr_type and selectable_attr_enum
      return result unless index
      case type
      when :boolean           then 'true'
      when :integer           then index.to_s 
      when :float, :decimal   then "#{index.to_s}.0"
      when :datetime          then 'DateTime.now'
      when :timestamp, :time  then 'Time.now'
      when :date              then 'Date.today'
      when :string            then "'some #{name} #{index}'"
      when :text              then "\"some #{name} #{index}\ninclude multilines\""
      else
        "'some #{name} #{index}'"
      end
    end
  end
  
  attr_reader :model_base_name, :model_attributes, :model_class_path
  attr_reader :nested_attribute_names, :nested_attribute_reflections
  attr_reader :nested_attribute_name, :nested_attribute_name_single
  attr_reader :reflection, 
              :reflection_class_name,
              :reflection_class,
              :reflection_attributes,
              :reflection_key,
              :reflection_name_to_model,
              :reflection_key_to_model,
              :reflection_attribute_for_error

  def initialize(runtime_args, runtime_options = {})
    super(runtime_args, runtime_options)
    begin
      @model_class = class_name.constantize
      @model_class_path = class_name.underscore
      @model_base_name = @model_class_path.split('/').last

      usage if @args.empty?
      @nested_attribute_names = @args.any?{|arg| arg == 'all'} ?
        @model_class.reflections.map{|key, obj| obj.accepts_allow_destroy ? key.to_s : nil} : @args.dup
      # 存在チェックとreflectionの準備
      @nested_attribute_reflections = @nested_attribute_names.map do |nested_attribute_name|
        reflection = @model_class.reflections[nested_attribute_name.to_sym]
        unless reflection
          usage("#{nested_attribute_name} not found by reflections (belongs_to/has_one/has_many/has_and_belongs_to_many)")
        end
        unless reflection.accepts_allow_destroy
          usage("#{nested_attribute_name} doesn't habe nested_attributes. So you can write after #{reflection.macro}in #{class_name}:\n  accepts_nested_attributes_for :#{reflection.name}")
        end
        reflection
      end
      except_col_names = ['id']

      # 複数個指定されている場合は、#manifestでdependencyによって呼び出され直すので、以下の変数の設定は不要。
      return unless @nested_attribute_reflections.length == 1
      @model_attributes = prepare_attributes(@model_class)

      @nested_attribute_name = @nested_attribute_names.first
      @nested_attribute_name_single = @nested_attribute_name.singularize
      @reflection = @nested_attribute_reflections.first
      @reflection_class_name = @reflection.class_name
      @reflection_class = @reflection_class_name.constantize
      @reflection_attributes = prepare_attributes(@reflection_class)
      @reflection_key = @reflection.primary_key_name
      key, to_model_reflection = @reflection_class.reflections.detect do |key, ref| 
        (ref.association_foreign_key ==  @reflection_key) && 
          (ref.class_name == class_name)
      end
      if to_model_reflection
        @reflection_attributes = @reflection_attributes.reject do |attr|
          attr.name == @reflection_key
        end
      end
      @reflection_name_to_model = to_model_reflection ? to_model_reflection.name : nil
      @reflection_key_to_model = to_model_reflection ? to_model_reflection.association_foreign_key : nil

      reflection_attr_for_error = @reflection_attributes.detect{|attr| [:string, :text].include?(attr.type)}
      @reflection_attribute_for_error = reflection_attr_for_error ? reflection_attr_for_error.name : nil
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n  ")
      raise e
    end
  end

  def prepare_attributes(model_class)
    except_col_names = ['id']
    columns = model_class.columns.select{|col| !except_col_names.include?(col.name) }
    columns = columns.select{|col| !%w(created_at updated_at).include?(col.name)} unless options[:add_timestamps]

    column_to_reflection = {}
    model_class.reflections.each do |name, reflection|
      column_to_reflection[reflection.primary_key_name.to_s] = reflection
    end

    ignore_selectable_attr = options[:ignore_selectable_attr] || !(Module.const_get(:SelectableAttr) rescue nil)
    result = columns.map do |column| 
      attr = Attribute.new(self, column, column_to_reflection[column.name.to_s])
      unless ignore_selectable_attr
        attr.selectable_attr_type = model_class.selectable_attr_type_for(column.name.to_s)
        if attr.selectable_attr_type
          attr.selectable_attr_base_name = model_class.enum_base_name(column.name.to_s)
          attr.selectable_attr_enum = model_class.enum_for(column.name.to_s)
        end
      end
      attr
    end
    result
  end


  def manifest
    record do |m|
      # 関連が複数指定された場合は、dependencyで関連性毎に呼び出します。
      if @nested_attribute_reflections.length > 1
        @nested_attribute_names.each do |nested_attribute_name|
          m.dependency 'nested_attributes_spec', [class_name, nested_attribute_name]
        end
        return
      end
      
      m.directory(File.join('spec/models', model_class_path))

      m.template('nested_attributes_spec.rb', 
        File.join('spec/models', "#{@model_class_path}_#{reflection.name}_attributes_spec.rb"))
    end
  end


  protected

  def banner
    "Usage: #{$0} nested_attributes_spec ModelName [all] [accepted_nested_attribute_name1] ..."
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--ignore-selectable-attr",
      "Don't generate field for selectable_attr plugin") { |v| options[:ignore_selectable_attr] = v }
  end
end
