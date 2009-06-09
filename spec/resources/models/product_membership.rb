class ProductMembership < ActiveRecord::Base
  belongs_to :product
  accepts_nested_attributes_for(:product)

  belongs_to :person
  accepts_nested_attributes_for(:person)

  def name_for_nested_ajax(context = nil)
    case context.to_s
    when /^Product/ then
      person.name_for_nested_ajax
    when /^Person/ then
      product.name_for_nested_ajax
    when ""
      "%s - %s" % [product.name_for_nested_ajax, person.name_for_nested_ajax]
    else
      raise ArgumentError, "Unknown context #{context.inspect}"
    end
  end


end
