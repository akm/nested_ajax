require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * controller_class_nesting_depth %>/../../spec_helper')

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "/<%= controller_file_path %>/edit.<%= default_file_extension %>" do
  include <%= controller_class_name %>Helper
  
  before(:each) do
    assigns[:<%= file_name %>] = @<%= file_name %> = stub_model(<%= class_name %>,
      :new_record? => false<%= output_attributes.empty? ? '' : ',' %>
<% output_attributes.each_with_index do |attribute, attribute_index| -%>
      :<%= attribute.name %> => <%= attribute.default_value %><%= attribute_index == output_attributes.length - 1 ? '' : ','%>
<% end -%>
    )
  end

  it "renders the edit <%= file_name %> form" do
    render
    
    response.should have_tag("form[action=?][method=post]", url_for(:controller => '<%= controller_name %>', :action => 'update', :id => @<%= file_name %>.id)) do
      with_tag('input[name=_method][value="put"]')
<% for attribute in output_attributes -%>
<% if attribute.belongs_to? -%>
      with_tag("input[id=?][type=text]", /<%= class_name %>_\d+_<%= attribute.reflection.name %>_display/)
      with_tag("input[id=?][type=?][name=?]", /<%= class_name %>_\d+_<%= attribute.reflection.name %>_fk/, /text|hidden/i, "<%= file_name %>[<%= attribute.name %>]")
<% else -%>
      with_tag("<%= attribute.input_type -%>#<%= file_name %>_<%= attribute.name %>[name=?]", "<%= file_name %>[<%= attribute.name %>]")
<% end -%>
<% end -%>
    end
  end
end


