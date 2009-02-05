module LiveValidations
  class Adapter
    # The methods individual adapters uses to implement itself.
    module AdapterMethods
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
      
      def response(name, &block)
        self.validation_responses ||= {}
        self.validation_responses[name] = ValidationResponse.new(&block)
      end
    end
  end
end