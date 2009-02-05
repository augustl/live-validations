module LiveValidations
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Where the html options are foo_field(:fieldname, :html => {})
    helpers_with_one_option_hash = field_helpers + %w(hidden_field fields_for) - %w(label)
    
    # Where the HTML options are foo_field(:fieldname, {:options => 'here'}, {:html_options => 'here'})
    helpers_with_two_option_hashes = %w(date_select datetime_select time_select) +
    %w(collection_select select country_select time_zone_select)
    

    helpers_with_one_option_hash.each do |helper|
      define_method(helper) do |attribute, *args|
        tag_attributes_data = @template.adapter_instance.tag_attributes_data[attribute]
        
        if tag_attributes_data
          options = args.extract_options!
          options.merge!(tag_attributes_data)
          super(attribute, *(args << options))
        else
          super
        end
      end
    end
    
    helpers_with_two_option_hashes.each do |helper|
      define_method(helper) do |attribute, *args|
        tag_attributes_data = @template.adapter_instance.tag_attributes_data[attribute]
        
        if tag_attributes_data
          # We have both options and html_options
          if args[-1].is_a?(Hash) && args[-2].is_a?(Hash)
            html_options = args.pop
            options = args.pop
            
            html_options.merge!(tag_attributes_data)
            args << options
            args << html_options
            super(attribute, *args)
          # No html_options was specified
          else
            html_options = tag_attributes_data
            args << {} unless args[-1].is_a?(Hash)
            args << html_options
            super(attribute, *args)
          end
        else
          super
        end
      end
    end
  end
end