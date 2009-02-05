module LiveValidations
  module Adapters
    # Adapter for http://www.validatious.org/
    class Validatious < LiveValidations::Adapter
      validates :presence do |v|
        v.tag_attributes[:class] = 'required'
      end
  
      validates :length do |v|
        v.tag_attributes[:class] = "min-length #{v.callback.options[:minimum]}" if v.callback.options[:minimum]
        v.tag_attributes[:class] = "max-length #{v.callback.options[:maximum]}" if v.callback.options[:maximum]
      end
  
      validates :numericality do |v|
        v.tag_attributes[:class] = "numeric"
      end
  
      validates :confirmation do |v|
      end
  
      validates :format do |v|
      end
  
      validates :uniqueness do |v|
      end
      
      form_for_options do |o|
        o.merge!(:html => {:class => 'validate'})
      end
    end
  end
end