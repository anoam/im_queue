# frozen_string_literal: trueparams

# Service object for planing message sending
class PlanningService
  # Runs service and returns result
  # @param params [#message, #send_at, #receivers]
  # @return [PlanningService]
  def self.call(params)
    new(params).tap { |object| object.send(:plan) }
  end

  # @param params [#message, #send_at, #receivers]
  def initialize(params)
    @params = params
  end

  # checks if there any consistency errors in params
  # @return [Boolean] true if any, false otherwise
  def errors?
    errors.any?
  end

  # params' consistency errors
  # @return [Array<String>] collection of errors
  def errors
    @errors ||= task_errors + receiver_errors
  end

  private

  attr_reader :params
  delegate :receivers, :send_at, to: :params

  def plan
    return if errors?

    receivers.each do |receiver_data|
      send_queue.perform_in(
        send_at,
        receiver_data.im,
        receiver_data.identifier,
        params.message
      )
    end
  end

  def task_errors
    errors = []

    errors.push('invalid messsage') if params.message.blank?

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

  def im_collection
    @im_collection ||= ImCollection.new
  end

  def send_queue
    SendingWorker
  end
end
