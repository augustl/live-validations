module LiveValidations
  module Adapters
    # Adapter for http://www.livevalidation.com/ (d'oh)
    class LivevalidationsDotCom < LiveValidations::Adapter
      validates :presence do |v, attribute|
        v.data["validators"] << %{
          var validator = new LiveValidation('#{v.prefix}_#{attribute}');
          validator.add(Validate.Presence, {failureMessage: "#{v.message_for(:blank)}"});
        }
      end
      
      validates :format do |v, attribute|
        v.data["validators"] << %{
          var validator = new LiveValidation('#{v.prefix}_#{attribute}');
          validator.add(Validate.Format, {pattern: #{v.format_regex}, failureMessage: "#{v.message_for(:invalid)}"});
        }
      end
      
      json do |a|
        a.data["validators"].join
      end
    end
  end
end