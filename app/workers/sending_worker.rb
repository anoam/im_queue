class SendingWorker
  include Sidekiq::Worker

  UnableToSendError = Class.new(StandardError)

  def perform(messenger, identifier, message)
    # Do something
  end
end
