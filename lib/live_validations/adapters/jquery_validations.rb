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
        v.json['minlength']   = v.callback.options[:minimum]
        v.json['maxlength']   = v.callback.options[:maximum]
        v.json['range']       = [v.callback.options[:within].first, v.callback.options[:within].last] if v.callback.options[:within]
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
        
        # Create a validation method
        identifier = Digest::SHA1.hexdigest(js_regex)
        v.adapter_instance.extras['declarations'] << "jQuery.validator.addMethod('#{identifier}', function(value) { return #{js_regex}.test(value)}, 'Invalid format.')"
        # TODO: Don't use a static message.
        
        # Assign the validation method to this validator.
        v.json[identifier] = true
      end
      
      validates :uniqueness do |v|
        # Next version. We need to do AJAX callbacks here.
      end
      
      json do |a|
        dom_id = ActionController::RecordIdentifier.dom_id(a.active_record_instance)
        %{
         #{a.extras['declarations'].join} 
         $('##{dom_id}').validate(#{{'rules' => a.json_data}.to_json})
        }
      end
    end
  end
end