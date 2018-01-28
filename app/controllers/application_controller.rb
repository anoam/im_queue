class ApplicationController < ActionController::API

  def plan
    unless form.valid?
      render json: { errors: ['invalid data'] }, status: :bad_request
      return
    end

    if planning_service.errors?
      render json: { errors: planning_service.errors }, status: :unprocessable_entity
      return
    end

    render json: { success: true }
  end

  private

  def planning_service
    @planning_service ||= PlanningService.call(form)
  end

  def planning_params
    params.permit!.to_h
  end

  def form
    @form ||= PlanForm.new(planning_params)
  end
end
