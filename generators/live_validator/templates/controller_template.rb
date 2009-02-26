class LiveValidationsController < ApplicationController
  def uniqueness
    responder = LiveValidations.current_adapter.validation_responses[:uniqueness]
    render :text => responder.respond(params)
  end
end