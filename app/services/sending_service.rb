# frozen_string_literal: true

# Service object for message sending
class SendingService
  # Runs service and returns result
  # @param messenger_name [String] messenger name
  # @param identifier [String] user identifier
  # @param message [String] message to send
  # @return [SendingService]
  def self.call(messenger_name, identifier, message)
    new(messenger_name, identifier, message).tap { |service| service.send(:send_message) }
  end

  # @param messenger_name [String] messenger name
  # @param identifier [String] user identifier
  # @param message [String] message to send
  def initialize(messenger_name, identifier, message)
    @messenger_name = messenger_name
    @identifier = identifier
    @message = message
  end

  # @return [Boolean] true if sending successful, false otherwise
  def success?
    @success
  end

  private

  attr_reader :messenger_name, :identifier, :message

  def send_message
    @success = messenger.send_message(identifier, message)
  end

  def messenger
    @messenger ||= im_collection.messenger(messenger_name)
  end

  def im_collection
    @im_collection ||= ImCollection.new
  end
end
