class PlanningService

  def plan(params)
    errors = validate(params)
    return errors if errors.any?

    # create task
  end

  private

  def validate(params)
    errors = []

    errors.push('invalid messsage') unless params[:message].present?
    begin
      Time.parse(params[:send_at])
    rescue ArgumentError
      errors.push('invalid send time')
    end

    errors + validate_receivers(params[:receivers])
  end

  def validate_receivers(receivers)
    errors = []
    receivers.each do |receiver|
      messenger = im_collection.messenger(receiver[:im])
      if messenger.nil?
        errors.push('invalid IM')
        break
      end

      errors.push('invalid identifier') unless messenger.identifier_valid?(receiver[:identifier])
    end

    errors.uniq
  end

  def im_collection
    @im_collection ||= ImCollection.new
  end
end
