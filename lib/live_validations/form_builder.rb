module LiveValidations
  class FormBuilder < ActionView::Helpers::FormBuilder
    helpers = field_helpers + 
      %w(date_select datetime_select time_select) + 
      %w(collection_select select country_select time_zone_select) - 
      %w(hidden_field label fields_for)
      
    helpers.each do |field_helper|
      define_method(field_helper) do |attribute, *args|
        super
      end
    end
  end
end