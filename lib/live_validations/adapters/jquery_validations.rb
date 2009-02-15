module LiveValidations
  module Adapters
    # Adapter for http://bassistance.de/jquery-plugins/jquery-plugin-validation/
    class JqueryValidations < LiveValidations::Adapter
      validates :presence do |v, attribute|
        v.json[attribute]['required'] = true
        v.messages[attribute]['required'] = v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:blank]
      end
      
      validates :acceptance do |v, attribute|
        v.json[attribute]['required'] = true
        v.messages[attribute]['required'] = v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:accepted]
      end
  
      validates :length do |v, attribute|
        if v.callback.options[:minimum]
          v.json[attribute]['minlength'] = v.callback.options[:minimum]
        end
        
        if v.callback.options[:maximum]
          v.json[attribute]['maxlength'] = v.callback.options[:maximum]
        end
        
        if v.callback.options[:within]
          v.json[attribute]['rangelength'] = [
            v.callback.options[:within].first,
            v.callback.options[:within].last
          ]
        end
        
        if v.callback.options[:is]
          length = v.callback.options[:is]
          add_custom_rule(v, "lengthIs#{length}", "return value.length == #{length}", "Please enter exactly #{length} characters.")
        end
      end
      
      validates :inclusion do |v, attribute|
        enum = v.callback.options[:in] || v.callback.options[:within]
        
        case enum
        when Range
          v.json[attribute]['range'] = [enum.first, enum.last]
        when Array
          add_custom_rule(v, attribute, Digest::SHA1.hexdigest(enum.inspect), "var list = #{enum.to_json}; for (var i=0; i<list.length; i++){if(list[i] == value) { return true; }}", v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:inclusion])
        end
      end
      
      # TODO: Exclusion. DRY!!111
  
      validates :numericality do |v, attribute|
        v.json[attribute]['digits'] = true
        v.json[attribute]['required'] = true
        v.messages[attribute]['digits'] = v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:not_a_number]
        v.messages[attribute]['required'] = v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:not_a_number]
      end
  
      validates :confirmation do |v, attribute|
        v.json["#{attribute}_confirmation"]['equalTo'] = "##{v.prefix}_#{attribute}"
        v.messages["#{attribute}_confirmation"]['equalTo'] = v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:confirmation]
      end
  
      validates :format do |v, attribute|
        # Build the validation regexp
        if v.callback.options[:live_validator]
          js_regex = v.callback.options[:live_validator]
        else
          regex = v.callback.options[:with]
          js_regex = "/#{regex.source}/"
          js_regex << 'i' if regex.casefold?
          # TODO: handle multiline as well
        end
        
        add_custom_rule(v, attribute, Digest::SHA1.hexdigest(js_regex), "return #{js_regex}.test(value)", v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:invalid])
      end
      
      if supports_controller_hooks?
        validates :uniqueness do |v, attribute|
          model_class = v.adapter_instance.active_record_instance.class.name
          v.json[attribute]['remote'] = "/live_validations/uniqueness?model_class=#{model_class}"
          v.messages[attribute]['remote'] = v.callback.options[:message] || I18n.translate('activerecord.errors.messages')[:taken]
        end
      
        response :uniqueness do |r|
          column  = r.params[r.params[:model_class].downcase].keys.first
          value   = r.params[r.params[:model_class].downcase][column]
          r.params[:model_class].constantize.count(:conditions => {column => value}) == 0
        end
      end
      
      json do |a|
        dom_id = ActionController::RecordIdentifier.dom_id(a.active_record_instance)
        %{
          #{custom_rules(a)}
          $('##{dom_id}').validate(#{{
            'rules' => a.json,
            'messages' => a.messages,
          }.to_json})
        }
      end
      
      def self.add_custom_rule(v, attribute, identifier, validation, message)
        v.adapter_instance.extras['declarations'] << <<-EOF
          jQuery.validator.addMethod('#{identifier}', function(value){
            #{validation}
          }, '#{message}')
        EOF
        v.json[attribute][identifier] = true
      end
      
      def self.custom_rules(a)
        a.extras['declarations'].join("\n")
      end
    end
  end
end