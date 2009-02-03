module LiveValidations
  module ViewHelpers
    def self.included(base)
      base.alias_method_chain :form_for, :live_validations
    end
    
    def form_for_with_live_validations(record_name_or_array, *args, &block)
      options = args.extract_options!
      
      if options[:live_validations]
        options.merge!(:builder => LiveValidations::FormBuilder)
        
        record = case record_name_or_array
        when Array
          array.last
        when ActiveRecord::Base
          record_name_or_array
        else
          raise ArgumentError, 'live_validation_form_for only supports an array (e.g. [:admin, @post]) or an active record instance (e.g. @post) as its first argument.'
        end

        self.adapter_instance = LiveValidations.current_adapter.new(record)
        form_for_without_live_validations(record_name_or_array, *(args << options), &block)
        concat(%{<script type="text/javascript">#{adapter_instance.render_json}</script>}, block.binding) if adapter_instance.utilizes_json?
      else
        form_for_without_live_validations(record_name_or_array, *args, &block)
      end
    end
    
    def adapter_instance=(record)
      @_adapter_instance = record
    end
    
    def adapter_instance
      @_adapter_instance
    end
  end
end