class Message

  def self.validate(params)
    errors = []

    errors.push('invalid messsage') unless params[:message].present?
    begin
      Time.parse(params[:send_at])
    rescue ArgumentError
      errors.push('invalid send time')
    end

    errors
  end

end
