module LiveValidations
  class Adapter
    # The methods individual adapters uses to implement itself.
    module AdapterMethods
      attr_internal_accessor :json_proc, :form_for_options_proc, :validation_hooks, :validation_responses
      # Hooks into a validation method. Example:
      #
      #  validates :presence do |v|
      #    v.json['required'] = true
      #  end
      #
      # Yields the validation hook.
      def validates(name, &block)
        self.validation_hooks ||= {}
        self.validation_hooks[name] = ValidationHook.new(&block)
      end

      # Defines the JSON output, if your adapters uses JSON data to define validations (some
      # adapters uses class names directly on form fields etc.). 
      #
      # Should return a string. This string is added below the form, inside a <script> tag.
      #
      # Implementation example:
      #
      #  json do |a|
      #    "doSomethingFancy(#{a.json})"
      #  end
      #
      # Yields the adapter.
      def json(&block)
        self.json_proc = block
      end
      
      # Controller responses for AJAX validations, e.g. polling the server to
      # check for uniqueness.
      def response(name, &block)
        self.validation_responses ||= {}
        self.validation_responses[name] = ValidationResponse.new(&block)
      end
      
      def form_for_options(&block)
        self.form_for_options_proc = block
      end
    end
  end
end