# frozen_string_literal: true

# actually just fake. According problem, should work with fake messengers.
class ImCollection
  FakeMessenger = Struct.new(:name) do
    def identifier_valid?(identifier)
      identifier != '' && identifier != 'invalid_identifier'
    end

    # rubocop:disable Rails/Output
    def send_message(identifier, message)
      p "Attempt to send message via `#{name}` to user `#{identifier}`"
      p "Message: #{message}"

      message != 'unprocessable'
    end
    # rubocop:enable Rails/Output
  end

  def messenger(name)
    messengers.find { |messenger| messenger.name == name }
  end

  private

  def messengers
    @messengers ||= [FakeMessenger.new('im1'), FakeMessenger.new('im2')]
  end
end
