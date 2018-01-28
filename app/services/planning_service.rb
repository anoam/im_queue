class PlanningService
  def plan(params)

    errors = Message.validate(params)
    return errors if errors.any?

    # check IMs and identities

    # create
  end

  private

  def im_collection

  end
end
