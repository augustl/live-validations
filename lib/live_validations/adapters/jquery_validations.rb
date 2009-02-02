module LiveValidations
  module Adapters
    # Adapter for http://bassistance.de/jquery-plugins/jquery-plugin-validation/
    class JqueryValidations < LiveValidations::Adapter
      validates :presence do |v|
        v.json['required'] = true
      end
      
      validates :acceptance do |v|
        v.json['required'] = true
      end
  
      validates :length do |v|
        # :within, :maximum, :minimum, or :is
        v.json['minlength']   = v.callback.options[:minimum] if v.callback.options[:minimum]
        v.json['maxlength']   = v.callback.options[:maximum] if v.callback.options[:maximum]
        v.json['rangelength'] = [v.callback.options[:within].first, v.callback.options[:within].last] if v.callback.options[:within]
        
        if v.callback.options[:is]
          length = v.callback.options[:is]
          add_custom_rule(v, "lengthIs#{length}", "value.length == #{length}", "Please enter exactly #{length} characters.")
        end
      end
  
      validates :numericality do |v|
        v.json['digits'] = true
      end
  
      validates :confirmation do |v|
        v.callback.options[:attributes].each do |attribute|
          prefix = v.adapter_instance.active_record_instance.class.name.downcase
          v.raw_json("#{prefix}[#{attribute}_confirmation]" => {'equalTo' => "##{prefix}_#{attribute}"})
        end
      end
  
      validates :format do |v|
        # Build the validation regexp
        if v.callback.options[:live_validator]
          js_regex = v.callback.options[:live_validator]
        else
          regex = v.callback.options[:with]
          js_regex = "/#{regex.source}/"
          js_regex << 'i' if regex.casefold? # case insensitive?
          # TODO: handle multiline as well
        end
        
        add_custom_rule(v, Digest::SHA1.hexdigest(js_regex), "#{js_regex}.test(value)", "Invalid format")
        # TODO: Don't use a static message.
      end
      
      validates :uniqueness do |v|
        # Next version. We need to do AJAX callbacks here.
      end
      
      json do |a|
        dom_id = ActionController::RecordIdentifier.dom_id(a.active_record_instance)
        %{
         #{render_custom_rules(a)} 
         $('##{dom_id}').validate(#{{'rules' => a.json_data}.to_json})
        }
      end
      
      def self.add_custom_rule(v, identifier, validation, message)
        v.adapter_instance.extras['declarations'] << "jQuery.validator.addMethod('#{identifier}', function(value) { return #{validation}}, '#{message}')"
        v.json[identifier] = true
      end
      
      def self.render_custom_rules(a)
        a.extras['declarations'].join("\n")
      end
    end
  end
end