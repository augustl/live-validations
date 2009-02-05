class LiveValidationsController < ApplicationController
  # Poll with /live_validations/uniqueness?model_class=User&column=username&value=theusername. Returns
  # either 'true' or 'false'. This should probably be converted to some adapter specific code.
  def uniqueness
    responder = LiveValidations.current_adapter.validation_responses[:uniqueness]
    render :text => responder.respond(params)
  end
end