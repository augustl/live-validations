class LiveValidatorGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory 'app/controllers'
      m.template 'controller_template.rb', "app/controllers/live_validations_controller.rb"
      m.route(%{map.connect "live_validations/:action", :controller => "live_validations"})
    end
  end
end

# Hijacked from restful_authentication
Rails::Generator::Commands::Create.class_eval do
  def route(spec)
    logger.route(spec)
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
      %{#{match}\n  #{spec}}
    end
  end
end
 
Rails::Generator::Commands::Destroy.class_eval do
  def route(spec)
    look_for = %{\n  #{spec}}
    logger.route(spec)
    gsub_file "config/routes.rb", /(#{look_for})/mi, ""
  end
end