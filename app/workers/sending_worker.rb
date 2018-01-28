class SendingWorker
  include Sidekiq::Worker

  def perform(messenger, identity, message)
    # Do something
  end
end
