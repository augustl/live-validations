module LiveValidations
  module FormBuilder
    def self.included(base)
      base.instance_eval {
        # Where the html options are foo_field(:fieldname, :html => {})
        helpers_with_one_option_hash = field_helpers - %w(label apply_form_for_options! fields_for)
        
        # Where the HTML options are foo_field(:fieldname, {:options => 'here'}, {:html_options => 'here'})
        helpers_with_two_option_hashes = %w(date_select datetime_select time_select) +
        %w(collection_select select time_zone_select)
        
        helpers_with_one_option_hash.each do |helper|
          define_method("#{helper}_with_live_validations") do |attribute, *args|
            tag_attributes = @template.adapter_instance && @template.adapter_instance[:tag_attributes] && @template.adapter_instance[:tag_attributes][attribute]

            if tag_attributes
              options = args.extract_options!
              options.merge!(tag_attributes)
              __send__("#{helper}_without_live_validations", attribute, *(args << options))
            else
              __send__("#{helper}_without_live_validations", attribute, *args)
            end
          end

          alias_method_chain helper, "live_validations"
        end

        helpers_with_two_option_hashes.each do |helper|
          define_method("#{helper}_with_live_validations") do |attribute, *args|
            tag_attributes = @template.adapter_instance && @template.adapter_instance[:tag_attributes] && @template.adapter_instance[:tag_attributes][attribute]

            if tag_attributes
              # We have both options and html_options
              if args[-1].is_a?(Hash) && args[-2].is_a?(Hash)
                html_options = args.pop
                options = args.pop

                html_options.merge!(tag_attributes)
                args << options
                args << html_options
                __send__("#{helper}_without_live_validations", *args)
              # No html_options was specified
              else
                html_options = tag_attributes
                args << {} unless args[-1].is_a?(Hash)
                args << html_options
                __send__("#{helper}_without_live_validations", attribute, *args)
              end
            else
              __send__("#{helper}_without_live_validations", attribute, *args)
            end
          end

          alias_method_chain helper, "live_validations"
        end
      }
    end
  end
end