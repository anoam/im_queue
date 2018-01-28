class PlanningService
  def plan(params)

    errors = validate_parameters(params)
    return errors if errors.any?


    # check IMs and identities

    # create
  end

  private


  def validate_parameters(params)
    errors = []

    errors.push('invalid messsage') unless params[:message].present?
    begin
      Time.parse(params[:send_at])
    rescue ArgumentError
      errors.push('invalid send time')
    end


    errors
  end

  def im_collection

  end
end
