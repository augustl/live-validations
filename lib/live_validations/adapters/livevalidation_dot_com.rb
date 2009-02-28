module LiveValidations
  module Adapters
    # Adapter for http://www.livevalidation.com/ (d'oh)
    class LivevalidationDotCom < LiveValidations::Adapter
      setup do |v|
        v[:validators] = []
      end
      
      validates :presence do |v, attribute|
        v[:validators] << %{
          var validator = new LiveValidation('#{v.prefix}_#{attribute}');
          validator.add(Validate.Presence, {failureMessage: "#{v.message_for(:blank)}"});
        }
      end
      
      validates :format do |v, attribute|
        v[:validators] << %{
          var validator = new LiveValidation('#{v.prefix}_#{attribute}');
          validator.add(Validate.Format, {pattern: #{v.format_regex}, failureMessage: "#{v.message_for(:invalid)}"});
        }
      end
      
      validates :numericality do |v, attribute|
        v[:validators] << %{
          var validator = new LiveValidation('#{v.prefix}_#{attribute}');
          validator.add(Validate.Numericality, {onlyInteger: true, failureMessage: "#{v.message_for(:not_a_number)}"})
        }
      end
      
      validates :length do |v, attribute|
        if v.callback.options[:minimum]
          v[:validators] << %{
            var validator = new LiveValidation('#{v.prefix}_#{attribute}');
            validator.add(Validate.Length, {minimum: #{v.callback.options[:minimum]}});
          }
        end
        
        if v.callback.options[:maximum]
          v[:validators] << %{
            var validator = new LiveValidation('#{v.prefix}_#{attribute}');
            validator.add(Validate.Length, {maximum: #{v.callback.options[:maximum]}});
          }
        end
        
        if v.callback.options[:within]
          v[:validators] << %{
            var validator = new LiveValidation('#{v.prefix}_#{attribute});
            validator.add(Validate.Length, {minimum: #{v.callback.options[:within].first}, maximum: #{v.callback.options[:within].last}});
          }
        end
        
        if v.callback.options[:is]
          v[:validators] << %{
            var validator = new LiveValidation('#{v.prefix}_#{attribute}');
            validator.add(Validate.Length, {is: #{v.callback.options[:is]}});
          }
        end
      end
      
      renders_inline do |a|
        a[:validators].join
      end
    end
  end
end