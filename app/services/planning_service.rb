class PlanningService

  def self.call(params)
    new(params).tap { |object| object.send(:plan)}
  end

  def initialize(params)
    @params = params
  end

  def errors?
    errors.any?
  end

  def errors
    @errors ||= task_errors + receiver_errors
  end

  private
  attr_reader :params

  def plan
    return if errors?

    receivers.each do |receiver_data|
      send_queue.perform_in(
          Time.parse(params[:send_at]),
          receiver_data[:im],
          receiver_data[:identifier],
          params[:message]
      )
    end
  end

  def task_errors
    errors = []

    errors.push('invalid messsage') unless params[:message].present?
    errors.push('invalid send time') if time.nil?

    errors
  end

  def receiver_errors
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

  def receivers
    params[:receivers]
  end

  def im_collection
    @im_collection ||= ImCollection.new
  end

  def send_queue
    SendingWorker
  end

  def time
    @time ||= Time.parse(params[:send_at])
  rescue ArgumentError
    nil
  end
end
