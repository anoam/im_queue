class ApplicationController < ActionController::API

  def plan
    unless schema_validator.validate(schema, params.permit!.to_h)
      render json: { errors: ['invalid data'] }, status: :bad_request
      return
    end

    errors = planning_service.plan(params)

    unless errors.nil?
      render json: { errors: errors }, status: :unprocessable_entity
      return
    end

    render json: { success: true }
  end

  private

  def planning_service
    @planning_service ||= PlanningService.new
  end

  def schema_validator
    JSON::Validator
  end

  def schema
    {
      type: 'object',
      required: %i(message receivers send_at),
      properties: {
        message: { type: 'string' },
        send_at: { type: 'string' },
        receivers: {
          type: 'array',
          items:
            {
              type: 'object',
              required: %i(im identifier),
              properties: {
                im: { type: 'string' },
                identifier: { type: 'string' }
              }
            }

        }
      }
    }
  end
end
