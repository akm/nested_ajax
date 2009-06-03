module NestedAjax
  module NameToDisplay
    def self.included(base)
      base.extend(ClassMethods)
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
    end

  end
end
