module LiveValidations
  module ActiveRecordHooks
    VALIDATION_METHODS = %w(confirmation acceptance presence length uniqueness format inclusion exclusion numericality)
    
    def self.included(base)
      base.class_eval { include InstanceMethods }
      
      # Add some extra data to the validation stacks, so that we can pull out the validation method
      # and which attributes it is going to validate.
      class << base
        VALIDATION_METHODS.each do |validation_method|
          class_eval %{
            def validates_#{validation_method}_of_with_live_validation_hooks(*args, &block)
              options = args.extract_options!
              options.merge!(:validation_method => :#{validation_method}, :attributes => args.dup)
              validates_#{validation_method}_of_without_live_validation_hooks(*(args << options), &block)
            end
            
            alias_method_chain :validates_#{validation_method}_of, :live_validation_hooks
          }
        end
      end
    end
    
    module InstanceMethods
      def validation_callback_for(attribute)
        validation_callbacks.select {|callback| callback.options[:attributes].include?(attribute) }
      end
      
      def validation_callbacks
        on = [:save, (new_record? ? :create : :update)]
        self.class.validate_callback_chain.select {|callback| callback.kind == :validate && on.include?(callback.options[:on]) }
      end
    end
  end
end