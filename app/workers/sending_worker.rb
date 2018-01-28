class SendingWorker
  include Sidekiq::Worker

  UnableToSendError = Class.new(StandardError)

  def perform(messenger, identifier, message)
    result = service.call(messenger, identifier, message)

    unless result.success?
      raise(UnableToSendError, "messenger: #{messenger}, identifier: #{identifier}, message: #{message}")
    end
  end

  private

  def service
    SendingService
  end
end
