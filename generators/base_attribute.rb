class BaseAttribute < Rails::Generator::GeneratedAttribute
  
  attr_reader :reflection
  attr_accessor :selectable_attr_type, :selectable_attr_base_name, :selectable_attr_enum
  
  def initialize(column, reflection = nil)
    @column = column
    @name, @type = column.name, column.type.to_sym
    @reflection = reflection
  end
  
  def belongs_to?
    @reflection && (@reflection.macro == :belongs_to)
  end

  def default_value(for_view = false)
    if selectable_attr_type and selectable_attr_enum
      case selectable_attr_type
      when :single
        entry = selectable_attr_enum.entries.first
        return entry.send(for_view ? :name : :id).inspect
      when :multi
        return selectable_attr_enum.entries.map(for_view ? :name : :id).inspect
      end
    end
    case type
    when :boolean           then 'true'
    when :integer           then '1' 
    when :float, :decimal   then '1.0'
    when :datetime          then 'DateTime.now'
    when :timestamp, :time  then 'Time.now'
    when :date              then 'Date.today'
    when :string            then "'some #{name}'"
    when :text              then "\"some #{name}\ninclude multilines\""
    else
      "'some #{name}'"
    end
  end
  
  def name_to_show
    case selectable_attr_type
    when :single
      "#{selectable_attr_base_name}_name"
    when :multi
      "#{selectable_attr_base_name}_names.join(', ')"
    else
      name
    end
  end
  
  def name_in_code
    case selectable_attr_type
    when :single
      "#{selectable_attr_base_name}_key"
    when :multi
      "#{selectable_attr_base_name}_keys"
    else
      name
    end
  end
  
end
