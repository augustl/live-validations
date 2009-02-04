class LiveValidationsController < ApplicationController
  session :off
  
  # Poll with /live_validations/uniqueness?model_class=User&column=username&value=theusername. Returns
  # either 'true' or 'false'. This should probably be converted to some adapter specific code.
  def uniqueness
    model_class = params[:model_class].constantize
    column      = params[params[:model_class].downcase].keys.first
    value       = params[params[:model_class].downcase][column]
    
    render :text => (model_class.count(:conditions => {column => value}) == 0)
  end
end