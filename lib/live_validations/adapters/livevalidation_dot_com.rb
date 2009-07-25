module LiveValidations
  module Adapters
    # Adapter for http://www.livevalidation.com/ (d'oh)
    class LivevalidationDotCom < LiveValidations::AdapterBase
      setup do |v|
        v[:validators] = Hash.new {|hash, key| hash[key] = {} }
      end
      
      validates :presence do |v, attribute|
        v[:validators][attribute]['Presence'] = {:failureMessage => v.message_for(attribute, :blank)}
      end
      
      validates :format do |v, attribute|
        # FIXME: The regexp outputs as a string, not a regex, in the javascripts.
        v[:validators][attribute]['Format'] = {:pattern => v.regex, :failureMessage => v.message_for(attribute, :invalid)}
      end
      
      validates :numericality do |v, attribute|
        v[:validators][attribute]["Numericality"] = {:onlyInteger => true, :failureMessage => v.message_for(attribute, :not_a_number)}
      end
      
      validates :length do |v, attribute|
        if v.callback.options[:minimum]
          v[:validators][attribute]["Length"] = {:minimum => v.callback.options[:minimum], :failureMessage => v.message_for(attribute, :too_short, :count => v.callback.options[:minimum])}
        end
        
        if v.callback.options[:maximum]
          v[:validators][attribute]["Length"] = {:maximum => v.callback.options[:maximum], :failureMessage => v.message_for(attribute, :too_long, :count => v.callback.options[:maximum])}
        end
        
        if v.callback.options[:within]
          v[:validators][attribute]["Length"] = {
            :minimum => v.callback.options[:within].first,
            :maximum => v.callback.options[:within].last,
            :tooShortMessage => v.message_for(attribute, :too_short, :count => v.callback.options[:within].first),
            :tooLongMessage => v.message_for(attribute, :too_long, :count => v.callback.options[:within].last)
          }
        end
        
        if v.callback.options[:is]
          v[:validators][attribute]["Length"] = {:is => v.callback.options[:is]}
        end
      end
      
      validates :inclusion do |v, attribute|
        enum = v.callback.options[:in] || v.callback.options[:within]
        
        # In case it's a range of numbers, we do all this so that we can
        # use the numericality range validation.
        case enum
        when Range
          case enum.first
          when Numeric
            v[:validators][attribute]["Numericality"] = {:minimum => enum.first, :maximum => enum.last, :failureMessage => v.message_for(attribute, :inclusion)}
          else
            v[:validators][attribute]["Inclusion"] = {:within => enum.to_a, :failureMessage => v.message_for(attribute, :inclusion)}
          end
        when Array
          v[:validators][attribute]["Inclusion"] = {:within => enum.to_a, :failureMessage => v.message_for(attribute, :inclusion)}
        end
      end
      
      validates :exclusion do |v, attribute|
        enum = v.callback.options[:in] || v.callback.options[:within]
        v[:validators][attribute]["Exclusion"] = {:within => enum.to_a, :failureMessage => v.message_for(attribute, :exclusion)}
      end
      
      validates :acceptance do |v, attribute|
        v[:validators][attribute]["Acceptance"] = {:failureMessage => v.message_for(attribute, :accepted)}
      end
      
      validates :confirmation do |v, attribute|
        v[:validators]["#{attribute}_confirmation".to_sym]["Confirmation"] = {:match => "#{v.prefix}_#{attribute}"}
      end
      
      renders_inline do |a|
        local_options = {}
        local_options["validMessage"] = LiveValidations.options[:default_valid_message]
        local_options["onlyOnBlur"] = LiveValidations.options[:validate_on_blur]
        
        local_options.delete_if {|k, v| v.nil? }
        
        a[:validators].map do |attribute, options|
          validators = options.map {|v, attrs| %{validator.add(Validate.#{v}, #{attrs.to_json});} }.join("\n")
          %{
            var validator = new LiveValidation('#{a.prefix}_#{attribute}', #{local_options.to_json});
            #{validators}
          }
        end.join
      end
    end
  end
end