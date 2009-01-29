module LiveValidations
  module Adapters
    # Adapter for http://www.validatious.org/
    class Validatious < LiveValidations::Adapter
      validates :presence do |v|
        v.tag_attributes[:class] = 'required'
      end
  
      validates :length do |v|
      end
  
      validates :numericality do |v|
      end
  
      validates :confirmation do |v|
      end
  
      validates :format do |v|
      end
  
      validates :uniqueness do |v|
      end
    end
  end
end