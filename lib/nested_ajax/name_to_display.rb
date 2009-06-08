require 'nested_ajax'

module NestedAjax
  module NameToDisplay
    def self.included(base)
      base.extend(ClassMethods)
      base.instance_eval do
        alias :belongs_to_without_nested_ajax :belongs_to
        alias :belongs_to :belongs_to_with_nested_ajax

        alias :has_many_without_nested_ajax :has_many
        alias :has_many :has_many_with_nested_ajax

        alias :has_one_without_nested_ajax :has_one
        alias :has_one :has_one_with_nested_ajax
      end
    end

    module ClassMethods
      # If you want to use complex find or name for nested_ajax,
      # define an instance method
      #   def name_for_nested_ajax(context = {})
      #     # return "name of record for nested_ajax"
      #   end
      # 
      # and define an class method
      #   def self.find_with_name(name, context = {})
      #     # return [record1, record2]
      #   end
      def name_for_nested_ajax(attr_name)
        define_method(:name_for_nested_ajax){|*runtime_args| send(attr_name)}
        instance_eval %{ 
          def find_with_name(name, context = {})
            self.find(:all, :conditions => ["#{attr_name} like ?", "%\#{name}%"], :order => :#{attr_name})
          end
        }
      end

      def belongs_to_with_nested_ajax(*args, &block)
        result = belongs_to_without_nested_ajax(*args.dup, &block)
        define_name_for_nested_ajax(*args)
        result
      end

      def has_many_with_nested_ajax(*args, &block)
        result = has_many_without_nested_ajax(*args.dup, &block)
        define_name_for_nested_ajax(*args)
        result
      end

      def has_one_with_nested_ajax(*args, &block)
        result = has_one_without_nested_ajax(*args.dup, &block)
        define_name_for_nested_ajax(*args)
        result
      end

      def define_name_for_nested_ajax(*args)
        args.extract_options!
        args.each do |association_name|
          self.module_eval(%{
            def #{association_name}_name_for_nested_ajax
              #{association_name}.name_for_nested_ajax if #{association_name}
            end
          })
        end
      end
    end

  end
end
