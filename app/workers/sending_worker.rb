# frozen_string_literal: true

# Sidekiq's worker for sending message
class SendingWorker
  include Sidekiq::Worker

  UnableToSendError = Class.new(StandardError)

  # Perform sending
  # @param messenger [String] messenger name
  # @param identifier [String] user identifier
  # @param message [String] message to send
  # @raise [UnableToSendError] if sending failed
  def perform(messenger, identifier, message)
    result = service.call(messenger, identifier, message)

    return if result.success?

    raise(UnableToSendError, "messenger: #{messenger}, identifier: #{identifier}, message: #{message}")
  end

  private

  def service
    SendingService
  end
end
