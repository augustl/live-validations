module LiveValidations
  module Adapters
    # Adapter for http://www.validatious.org/
    class Validatious < LiveValidations::Adapter
      validates :presence do |v|
        v.tag_attributes[:class] = 'required'
      end
  
      validates :length do |v|
        v.tag_attributes[:class] = "min-length_#{v.callback.options[:minimum]}" if v.callback.options[:minimum]
        v.tag_attributes[:class] = "max-length_#{v.callback.options[:maximum]}" if v.callback.options[:maximum]
      end
  
      validates :numericality do |v|
        v.tag_attributes[:class] = "numeric"
      end
  
      validates :confirmation do |v|
        v.callback.options[:attributes].each do |attribute|
          prefix = v.adapter_instance.active_record_instance.class.name.downcase
          v.raw_tag_attributes("#{attribute}_confirmation" => {:class => "confirmation-of_#{prefix}_#{attribute}"})
        end
      end
      
      validates :acceptance do |v|
        v.tag_attributes[:class] = 'required'
      end
      
      form_for_options do |o|
        o.merge!(:html => {:class => 'validate'})
      end
    end
  end
end