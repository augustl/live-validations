module LiveValidations
  module Adapters
    # Adapter for http://www.livevalidation.com/ (d'oh)
    class LivevalidationDotCom < LiveValidations::Adapter
      setup do |v|
        v[:validators] = Hash.new {|hash, key| hash[key] = {} }
      end
      
      validates :presence do |v, attribute|
        v[:validators][attribute]['Presence'] = {:failureMessage => v.message_for(:blank)}
      end
      
      validates :format do |v, attribute|
        # FIXME: The regexp outputs as a string, not a regex, in the javascripts.
        v[:validators][attribute]['Format'] = {:pattern => v.format_regex, :failureMessage => v.message_for(:invalid)}
      end
      
      validates :numericality do |v, attribute|
        v[:validators][attribute]["Numericality"] = {:onlyInteger => true, :failureMessage => v.message_for(:not_a_number)}
      end
      
      validates :length do |v, attribute|
        if v.callback.options[:minimum]
          v[:validators][attribute]["Length"] = {:minimum => v.callback.options[:minimum]}
        end
        
        if v.callback.options[:maximum]
          v[:validators][attribute]["Length"] = {:maximum => v.callback.options[:maximum]}
        end
        
        if v.callback.options[:within]
          v[:validators][attribute]["Length"] = {
            :minimum => v.callback.options[:within].first,
            :maximum => v.callback.options[:within].last
          }
        end
        
        if v.callback.options[:is]
          v[:validators][attribute]["Length"] = {:is => v.callback.options[:is]}
        end
      end
      
      renders_inline do |a|
        a[:validators].map do |attribute, options|
          validators = options.map {|v, attrs| %{validator.add(Validate.#{v}, #{attrs.to_json});} }.join("\n")
          %{
            var validator = new LiveValidation('#{a.prefix}_#{attribute}');
            #{validators}
          }
        end.join
      end
    end
  end
end