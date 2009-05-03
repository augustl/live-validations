module LiveValidations
  module FormBuilder
    def self.included(base)
      base.instance_eval {
        # Where the html options are foo_field(:fieldname, :html => {})
        helpers_with_one_option_hash = field_helpers.map(&:to_s) - %w(label apply_form_for_options! fields_for)
        
        # Where the HTML options are foo_field(:fieldname, {:options => 'here'}, {:html_options => 'here'})
        helpers_with_two_option_hashes = %w(date_select datetime_select time_select) +
        %w(collection_select select time_zone_select)
        
        helpers_with_one_option_hash.each do |helper|
          define_method("#{helper}_with_live_validations") do |attribute, *args|
            if @template.adapter_instance
              @template.adapter_instance.renders_attribute(attribute)
              
              if @template.adapter_instance.alters_tag_attributes?
                options = args.extract_options!
                options.merge!(@template.adapter_instance[:tag_attributes][attribute])
                args << options
              end
            end

            __send__("#{helper}_without_live_validations", attribute, *args)
          end

          alias_method_chain helper, "live_validations"
        end

        helpers_with_two_option_hashes.each do |helper|
          define_method("#{helper}_with_live_validations") do |attribute, *args|
            if @template.adapter_instance
              @template.adapter_instance.renders_attribute(attribute)
              
              if @template.adapter_instance.alters_tag_attributes?
                # We have both options and html_options
                if args[-1].is_a?(Hash) && args[-2].is_a?(Hash)
                  html_options = args.pop
                  options = args.pop

                  html_options.merge!(@template.adapter_instance[:tag_attributes][attribute])
                  args << options
                  args << html_options
                # No html_options was specified
                else
                  html_options = @template.adapter_instance[:tag_attributes][attribute]
                  args << {} unless args[-1].is_a?(Hash)
                  args << html_options
                end
              end
            end
            
            __send__("#{helper}_without_live_validations", attribute, *args)
          end

          alias_method_chain helper, "live_validations"
        end
      }
    end
  end
end