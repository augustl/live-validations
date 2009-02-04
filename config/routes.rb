ActionController::Routing::Routes.draw do |map|
  map.connect 'live_validations/:action', :controller => 'live_validations'
end