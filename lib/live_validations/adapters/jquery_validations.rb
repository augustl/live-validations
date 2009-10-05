module LiveValidations
  module Adapters
    # Adapter for http://bassistance.de/jquery-plugins/jquery-plugin-validation/
    class JqueryValidations < LiveValidations::AdapterBase
      setup do |v|
        v[:validators] = Hash.new {|hash, key| hash[key] = {} }
        v[:messages] = Hash.new {|hash, key| hash[key] = {} }
        v[:declarations] = []
      end
      
      validates :presence do |v, attribute|
        v[:validators][attribute]['required'] = true
        v[:messages][attribute]['required'] = v.message_for(attribute, :blank)
      end
      
      validates :acceptance do |v, attribute|
        v[:validators][attribute]['required'] = true
        v[:messages][attribute]['required'] = v.message_for(attribute, :accepted)
      end
  
      validates :length do |v, attribute|
        if v.callback.options[:minimum]
          v[:validators][attribute]['minlength'] = v.callback.options[:minimum]
        end
        
        if v.callback.options[:maximum]
          v[:validators][attribute]['maxlength'] = v.callback.options[:maximum]
        end
        
        if v.callback.options[:within]
          v[:validators][attribute]['rangelength'] = [
            v.callback.options[:within].first,
            v.callback.options[:within].last
          ]
        end
        
        if v.callback.options[:is]
          length = v.callback.options[:is]
          add_custom_rule(v, attribute, "lengthIs#{length}", "return value.length == #{length}", "Please enter exactly #{length} characters.")
        end
      end
      
      validates :inclusion do |v, attribute|
        enum = v.callback.options[:in] || v.callback.options[:within]
        
        case enum
        when Range
          v[:validators][attribute]['range'] = [enum.first, enum.last]
        when Array
          add_custom_rule(v, attribute, Digest::SHA1.hexdigest(enum.inspect), "var list = #{enum.to_json}; for (var i=0; i<list.length; i++){if(list[i] == value) { return true; }}", v.message_for(attribute, :inclusion))
        end
      end
      
      # TODO: Exclusion. DRY!!111
  
      validates :numericality do |v, attribute|
        v[:validators][attribute]['digits'] = true
        v[:validators][attribute]['required'] = true
        
        message = v.message_for(attribute, :not_a_number)
        v[:messages][attribute]['digits'] = message
        v[:messages][attribute]['required'] = message
      end
  
      validates :confirmation do |v, attribute|
        attribute_name = "#{attribute}_confirmation".to_sym
        v[:validators][attribute_name]['equalTo'] = "##{v.prefix}_#{attribute}"
        v[:validators][attribute_name]['required'] = true
        message = v.message_for(attribute, :confirmation)
        v[:messages][attribute_name]['equalTo'] = message
        v[:messages][attribute_name]['required'] = message
      end
  
      validates :format do |v, attribute|
        regex = v.regex.inspect
        add_custom_rule(v, attribute, Digest::SHA1.hexdigest(regex.inspect), "return #{regex}.test(value)", v.message_for(attribute, :invalid))
      end
      
      validates :uniqueness do |v, attribute|
        model_class = v.adapter_instance.active_record_instance.class.name
        v[:validators][attribute]['remote'] = "/live_validations/uniqueness?model_class=#{model_class}"
        v[:messages][attribute]['remote'] = v.message_for(attribute, :taken)
      end
    
      response :uniqueness do |r|
        column  = r.params[r.params[:model_class].downcase].keys.first
        value   = r.params[r.params[:model_class].downcase][column]
        r.params[:model_class].constantize.count(:conditions => {column => value}) == 0
      end
      
      renders_inline do |a|
        dom_id = ActionController::RecordIdentifier.dom_id(a.active_record_instance, a.active_record_instance.new_record? ? nil : :edit)
        rule_mapper = Proc.new {|returning, rule| returning.merge!("#{a.prefix}[#{rule[0]}]" => rule[1]) }
        
        validator_options             = (LiveValidations.options[:validator_settings] && LiveValidations.options[:validator_settings].dup) || {}
        validator_options['rules']    = a[:validators].inject({}, &rule_mapper)
        validator_options['messages'] = a[:messages].inject({}, &rule_mapper)
        
        %{
          #{custom_rules(a)}
          $('##{dom_id}').validate(#{to_json_with_function_awareness(validator_options)})
        }
      end
      
      def self.add_custom_rule(v, attribute, identifier, validation, message)
        v[:declarations] << <<-EOF
          jQuery.validator.addMethod('#{identifier}', function(value){
            #{validation}
          }, '#{message}')
        EOF
        v[:validators][attribute][identifier] = true
      end
      
      def self.custom_rules(a)
        a[:declarations].join("\n")
      end

      def self.to_json_with_function_awareness(validator_options)
        functions = {}
        function_strings = validator_options.select { |k, v| v.is_a?(String) && v.starts_with?('function') }
        function_strings.each_with_index do |function_string, i|
          function_key = "%function_#{i + 1}%"
          functions[function_key] = function_string.last
          validator_options[function_string.first] = function_key
        end
        functions.inject(validator_options.to_json) do |json, function|
          json.gsub(/"#{function.first}"/i, function.last)
        end
      end
    end
  end
end