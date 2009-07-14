require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe <%= class_name %> do
  
  before(:each) do
    @<%= model_base_name %>_attrs = {
<% model_attributes.each_with_index do |attr, attr_index| -%>
      '<%= attr.name %>' => <%= attr.default_value %><%= attr_index == model_attributes.length - 1 ? '' : ','%>
<% end -%>
    }
    @<%= model_base_name %>_<%= nested_attribute_name %>_attrs = [
<% (0..2).each do |index| -%>
      {
<% reflection_attributes.each_with_index do |attr, attr_index| -%>
        '<%= attr.name %>' => <%= attr.default_value(index) %><%= attr_index == model_attributes.length - 1 ? '' : ','%>
<% end -%>
      },
<% end -%>
    ]
    @<%= model_base_name %>_attrs_with_<%= nested_attribute_name %> = @<%= model_base_name %>_attrs.update(
      '<%= nested_attribute_name %>_attributes' => {
        '0' => @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[0],
        '1' => @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[1]
      }
      )
  end
  
  def check_valid(<%= model_base_name %>, options = nil)
    options = {
      :<%= nested_attribute_name %>_count => 2,
      :<%= nested_attribute_name %>_length => 2
    }.update(options || {})
    <%= model_base_name %>.errors.should be_empty
    <%= model_base_name %>.id.should_not be_nil
    
    <%= model_base_name %>.<%= nested_attribute_name %>.count.should == options[:<%= nested_attribute_name %>_count]
    <%= model_base_name %>.<%= nested_attribute_name %>.length.should == options[:<%= nested_attribute_name %>_length]
    <%= model_base_name %>.<%= nested_attribute_name %>.each do |<%= nested_attribute_name_single %>|
      <%= nested_attribute_name_single %>.errors.should be_empty
<% if reflection_name_to_model -%>
      <%= nested_attribute_name_single %>.<%= reflection_name_to_model %>.should_not be_nil
      <%= nested_attribute_name_single %>.<%= reflection_key_to_model %>.should == <%= model_base_name %>.id
<% end -%>
    end
  end


  describe "create" do
    it "valid" do
      <%= model_base_name %> = <%= class_name %>.new(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>)
      <%= model_base_name %>.<%= nested_attribute_name %>.length.should == 2

      <%= model_base_name %>.save!
      check_valid(<%= model_base_name %>)
      <%= nested_attribute_name_single %>_0 = <%= model_base_name %>.<%= nested_attribute_name %>[0]
<% reflection_attributes.each do |attr| -%>
      <%= nested_attribute_name_single %>_0.<%= attr.name %>.should == @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[0]['<%= attr.name %>']
<% end -%>
      <%= nested_attribute_name_single %>_1 = <%= model_base_name %>.<%= nested_attribute_name %>[1]
<% reflection_attributes.each do |attr| -%>
      <%= nested_attribute_name_single %>_1.<%= attr.name %>.should == @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[1]['<%= attr.name %>']
<% end -%>
    end

    it "invalid" do
      # deep copy
      invalid_attrs = YAML.load(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>.to_yaml)
<% if reflection_attribute_for_error -%>
      invalid_attrs['<%= nested_attribute_name %>_attributes']['1']['<%= reflection_attribute_for_error %>'] = "invalid value"
<% end -%>
      <%= model_base_name %> = <%= class_name %>.new(invalid_attrs)
      <%= model_base_name %>.<%= nested_attribute_name %>.length.should == 2

      <%= model_base_name %>.<%= nested_attribute_name %>[1].instance_eval do
        def validate
<% if reflection_attribute_for_error -%>
          errors.add(:<%= reflection_attribute_for_error %>, "something wrong!")
<% else -%>
          errors.add_to_base(:<%= reflection_attribute_for_error %>, "something wrong!")
<% end -%>
        end
      end

      lambda{ <%= model_base_name %>.save! }.should raise_error(ActiveRecord::RecordInvalid)
      
      <%= model_base_name %>.errors.should_not be_empty
      <%= model_base_name %>.errors.full_messages.should == ['<%= nested_attribute_name.camelize %> <%= reflection_attribute_for_error || 'base' %> something wrong!']
      <%= model_base_name %>.id.should be_nil
      <%= nested_attribute_name_single %>_0 = <%= model_base_name %>.<%= nested_attribute_name %>[0]
      <%= nested_attribute_name_single %>_0.errors.should be_empty
<% if reflection_name_to_model -%>
      <%= nested_attribute_name_single %>_0.<%= reflection_name_to_model %>.should be_nil
      <%= nested_attribute_name_single %>_0.<%= reflection_key_to_model %>.should == <%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
      <%= nested_attribute_name_single %>_0.<%= reflection_attribute_for_error %>.should == @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[0]['<%= reflection_attribute_for_error %>']
<% end -%>
      <%= nested_attribute_name_single %>_1 = <%= model_base_name %>.<%= nested_attribute_name %>[1]
      <%= nested_attribute_name_single %>_1.errors.full_messages.should == ['<%= (reflection_attribute_for_error || 'base').humanize %> something wrong!']
<% if reflection_name_to_model -%>
      <%= nested_attribute_name_single %>_1.<%= reflection_name_to_model %>.should be_nil
      <%= nested_attribute_name_single %>_1.<%= reflection_key_to_model %>.should == <%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
      <%= nested_attribute_name_single %>_1.<%= reflection_attribute_for_error %>.should == "invalid value"
<% end -%>
    end
  end
  
  describe "update" do
    before(:each) do
      <%= model_base_name %> = <%= class_name %>.new(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>)
      <%= model_base_name %>.save!
      @<%= model_base_name %> = <%= class_name %>.find(<%= model_base_name %>.id)
    end

    describe "update and update" do
      it "valid" do
        new_valid_attrs = YAML.load(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>.to_yaml)
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['0']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[0].id
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['1']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[1].id
<% if reflection_attribute_for_error -%>
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['1']['<%= reflection_attribute_for_error %>'] = "new valid value"
<% end -%>
        @<%= model_base_name %>.attributes = new_valid_attrs
        @<%= model_base_name %>.save!
        
        check_valid(@<%= model_base_name %>)
      end

      it "invalid" do
        new_invalid_attrs = YAML.load(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>.to_yaml)
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['0']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[0].id
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['1']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[1].id
<% if reflection_attribute_for_error -%>
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['1']['<%= reflection_attribute_for_error %>'] = "new invalid value"
<% end -%>
        @<%= model_base_name %>.attributes = new_invalid_attrs
        
        @<%= model_base_name %>.<%= nested_attribute_name %>[1].instance_eval do
          def validate
<% if reflection_attribute_for_error -%>
            errors.add(:<%= reflection_attribute_for_error %>, "something wrong!")
<% else -%>
            errors.add_to_base(:<%= reflection_attribute_for_error %>, "something wrong!")
<% end -%>
          end
        end

        lambda{ @<%= model_base_name %>.save! }.should raise_error(ActiveRecord::RecordInvalid)

        @<%= model_base_name %>.errors.should_not be_empty
        @<%= model_base_name %>.errors.full_messages.should == ['<%= nested_attribute_name.camelize %> <%= reflection_attribute_for_error || 'base' %> something wrong!']
        @<%= model_base_name %>.id.should_not be_nil
        @<%= model_base_name %>.<%= nested_attribute_name %>.length.should == 2
        <%= nested_attribute_name_single %>_0 = @<%= model_base_name %>.<%= nested_attribute_name %>[0]
        <%= nested_attribute_name_single %>_0.errors.should be_empty
<% if reflection_name_to_model -%>
        <%= nested_attribute_name_single %>_0.<%= reflection_name_to_model %>.should == @<%= model_base_name %>
        <%= nested_attribute_name_single %>_0.<%= reflection_key_to_model %>.should == @<%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
        <%= nested_attribute_name_single %>_0.<%= reflection_attribute_for_error %>.should == @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[0]['<%= reflection_attribute_for_error %>']
<% end -%>
        <%= nested_attribute_name_single %>_1 = @<%= model_base_name %>.<%= nested_attribute_name %>[1]
        <%= nested_attribute_name_single %>_1.errors.full_messages.should == ['<%= (reflection_attribute_for_error || 'base').humanize %> something wrong!']
<% if reflection_name_to_model -%>
        <%= nested_attribute_name_single %>_1.<%= reflection_name_to_model %>.should == @<%= model_base_name %>
        <%= nested_attribute_name_single %>_1.<%= reflection_key_to_model %>.should == @<%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
        <%= nested_attribute_name_single %>_1.<%= reflection_attribute_for_error %>.should == "new invalid value"
<% end -%>
      end
    end


    describe "update and delete" do
      it "valid" do
        new_valid_attrs = YAML.load(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>.to_yaml)
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['0']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[0].id
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['0']['_delete'] = "1"
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['1']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[1].id
<% if reflection_attribute_for_error -%>
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['1']['<%= reflection_attribute_for_error %>'] = "new valid value"
<% end -%>
        @<%= model_base_name %>.attributes = new_valid_attrs
        @<%= model_base_name %>.<%= nested_attribute_name %>[0].marked_for_destruction?.should == true
        
        @<%= model_base_name %>.save!
        
        check_valid(@<%= model_base_name %>, :<%= nested_attribute_name %>_count => 1, :<%= nested_attribute_name %>_length => 2)
      end

      it "invalid" do
        new_invalid_attrs = YAML.load(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>.to_yaml)
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['0']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[0].id
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['0']['_delete'] = "1"
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['1']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[1].id
<% if reflection_attribute_for_error -%>
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['1']['<%= reflection_attribute_for_error %>'] = "new invalid value"
<% end -%>
        @<%= model_base_name %>.attributes = new_invalid_attrs
        @<%= model_base_name %>.<%= nested_attribute_name %>[0].marked_for_destruction?.should == true
        
        @<%= model_base_name %>.<%= nested_attribute_name %>[1].instance_eval do
          def validate
<% if reflection_attribute_for_error -%>
            errors.add(:<%= reflection_attribute_for_error %>, "something wrong!")
<% else -%>
            errors.add_to_base(:<%= reflection_attribute_for_error %>, "something wrong!")
<% end -%>
          end
        end

        lambda{ @<%= model_base_name %>.save! }.should raise_error(ActiveRecord::RecordInvalid)

        @<%= model_base_name %>.errors.should_not be_empty
        @<%= model_base_name %>.errors.full_messages.should == ['<%= nested_attribute_name.camelize %> <%= reflection_attribute_for_error || 'base' %> something wrong!']
        @<%= model_base_name %>.id.should_not be_nil
        @<%= model_base_name %>.<%= nested_attribute_name %>.count.should == 2
        @<%= model_base_name %>.<%= nested_attribute_name %>.length.should == 2
        <%= nested_attribute_name_single %>_0 = @<%= model_base_name %>.<%= nested_attribute_name %>[0]
        <%= nested_attribute_name_single %>_0.errors.should be_empty
<% if reflection_name_to_model -%>
        <%= nested_attribute_name_single %>_0.<%= reflection_name_to_model %>.should == @<%= model_base_name %>
        <%= nested_attribute_name_single %>_0.<%= reflection_key_to_model %>.should == @<%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
        <%= nested_attribute_name_single %>_0.<%= reflection_attribute_for_error %>.should == @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[0]['<%= reflection_attribute_for_error %>']
<% end -%>
        <%= nested_attribute_name_single %>_1 = @<%= model_base_name %>.<%= nested_attribute_name %>[1]
        <%= nested_attribute_name_single %>_1.errors.full_messages.should == ['<%= (reflection_attribute_for_error || 'base').humanize %> something wrong!']
<% if reflection_name_to_model -%>
        <%= nested_attribute_name_single %>_1.<%= reflection_name_to_model %>.should == @<%= model_base_name %>
        <%= nested_attribute_name_single %>_1.<%= reflection_key_to_model %>.should == @<%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
        <%= nested_attribute_name_single %>_1.<%= reflection_attribute_for_error %>.should == "new invalid value"
<% end -%>
      end
    end


    describe "update and delete and insert" do
      it "valid" do
        new_valid_attrs = YAML.load(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>.to_yaml)
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['0']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[0].id
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['0']['_delete'] = "1"
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['1']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[1].id
<% if reflection_attribute_for_error -%>
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['1']['<%= reflection_attribute_for_error %>'] = "new valid value"
<% end -%>
        new_valid_attrs['<%= nested_attribute_name %>_attributes']['2'] = @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[2]
        @<%= model_base_name %>.attributes = new_valid_attrs
        @<%= model_base_name %>.<%= nested_attribute_name %>[0].marked_for_destruction?.should == true
        
        @<%= model_base_name %>.save!
        
        check_valid(@<%= model_base_name %>, :<%= nested_attribute_name %>_count => 2, :<%= nested_attribute_name %>_length => 3)
      end

      it "invalid" do
        new_invalid_attrs = YAML.load(@<%= model_base_name %>_attrs_with_<%= nested_attribute_name %>.to_yaml)
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['0']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[0].id
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['0']['_delete'] = "1"
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['1']['id'] = @<%= model_base_name %>.<%= nested_attribute_name %>[1].id
<% if reflection_attribute_for_error -%>
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['1']['<%= reflection_attribute_for_error %>'] = "new valid value"
<% end -%>
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['2'] = @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[2]
<% if reflection_attribute_for_error -%>
        new_invalid_attrs['<%= nested_attribute_name %>_attributes']['2']['<%= reflection_attribute_for_error %>'] = "new invalid value"
<% end -%>
        @<%= model_base_name %>.attributes = new_invalid_attrs
        @<%= model_base_name %>.<%= nested_attribute_name %>[0].marked_for_destruction?.should == true
        
        @<%= model_base_name %>.<%= nested_attribute_name %>[2].instance_eval do
          def validate
<% if reflection_attribute_for_error -%>
            errors.add(:<%= reflection_attribute_for_error %>, "something wrong!")
<% else -%>
            errors.add_to_base(:<%= reflection_attribute_for_error %>, "something wrong!")
<% end -%>
          end
        end

        lambda{ @<%= model_base_name %>.save! }.should raise_error(ActiveRecord::RecordInvalid)

        @<%= model_base_name %>.errors.should_not be_empty
        @<%= model_base_name %>.errors.full_messages.should == ['<%= nested_attribute_name.camelize %> <%= reflection_attribute_for_error || 'base' %> something wrong!']
        @<%= model_base_name %>.id.should_not be_nil
        @<%= model_base_name %>.<%= nested_attribute_name %>.count.should == 2
        @<%= model_base_name %>.<%= nested_attribute_name %>.length.should == 3
        <%= nested_attribute_name_single %>_0 = @<%= model_base_name %>.<%= nested_attribute_name %>[0]
        <%= nested_attribute_name_single %>_0.errors.should be_empty
<% if reflection_name_to_model -%>
        <%= nested_attribute_name_single %>_0.<%= reflection_name_to_model %>.should == @<%= model_base_name %>
        <%= nested_attribute_name_single %>_0.<%= reflection_key_to_model %>.should == @<%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
        <%= nested_attribute_name_single %>_0.<%= reflection_attribute_for_error %>.should == @<%= model_base_name %>_<%= nested_attribute_name %>_attrs[0]['<%= reflection_attribute_for_error %>']
<% end -%>
        <%= nested_attribute_name_single %>_1 = @<%= model_base_name %>.<%= nested_attribute_name %>[1]
        <%= nested_attribute_name_single %>_1.errors.should be_empty
<% if reflection_name_to_model -%>
        <%= nested_attribute_name_single %>_1.<%= reflection_name_to_model %>.should == @<%= model_base_name %>
        <%= nested_attribute_name_single %>_1.<%= reflection_key_to_model %>.should == @<%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
        <%= nested_attribute_name_single %>_1.<%= reflection_attribute_for_error %>.should == "new valid value"
<% end -%>
        <%= nested_attribute_name_single %>_2 = @<%= model_base_name %>.<%= nested_attribute_name %>[2]
        <%= nested_attribute_name_single %>_2.errors.full_messages.should == ['<%= (reflection_attribute_for_error || 'base').humanize %> something wrong!']
<% if reflection_name_to_model -%>
        <%= nested_attribute_name_single %>_2.<%= reflection_name_to_model %>.should == @<%= model_base_name %>
        <%= nested_attribute_name_single %>_2.<%= reflection_key_to_model %>.should == @<%= model_base_name %>.id
<% end -%>
<% if reflection_attribute_for_error -%>
        <%= nested_attribute_name_single %>_2.<%= reflection_attribute_for_error %>.should == "new invalid value"
<% end -%>
      end
    end

  end
  
  
end
