module LiveValidations
  module Adapters
    # Adapter for http://www.validatious.org/
    class Validatious < LiveValidations::Adapter
      validates :presence do |v, attribute|
        v.tag_attributes[attribute][:class] = 'required'
      end
  
      validates :length do |v, attribute|
        if v.callback.options[:minimum]
          v.tag_attributes[attribute][:class] = "min-length_#{v.callback.options[:minimum]}"
        end
        
        if v.callback.options[:maximum]
          v.tag_attributes[attribute][:class] = "max-length_#{v.callback.options[:maximum]}"
        end
      end
  
      validates :numericality do |v, attribute|
        v.tag_attributes[attribute][:class] = "numeric"
      end
  
      validates :confirmation do |v, attribute|
        v.tag_attributes["#{attribute}_confirmation"][:class] = "confirmation-of_#{v.prefix}_#{attribute}"
      end
      
      validates :acceptance do |v, attribute|
        v.tag_attributes[attribute][:class] = 'required'
      end
      
      form_for_options do |o|
        o.merge!(:html => {:class => 'validate'})
      end
    end
  end
end