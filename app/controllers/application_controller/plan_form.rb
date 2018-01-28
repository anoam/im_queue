# frozen_string_literal: true

# Form-object for message planing
class ApplicationController::PlanForm
  InvalidSchema = Class.new(StandardError)
  Receiver = Struct.new(:im, :identifier)

  # @param raw_data [Hash] raw user data
  def initialize(raw_data)
    @raw_data ||= raw_data
  end

  # checks if data valid
  # @return [Boolean]
  def valid?
    schema_validator.validate(schema, raw_data)
  end

  # Message text
  # @return [String]
  # @raise [InvalidSchema] if data is invalid
  def message
    raise InvalidSchema unless valid?
    raw_data[:message]
  end

  # Planning time to send
  # @return [Time]
  # @raise [InvalidSchema] if data is invalid
  def send_at
    raise InvalidSchema unless valid?

    @send_at ||= Time.zone.parse(raw_data[:send_at])
  end

  # List of receivers
  # @return [Array<Receiver>]
  # @raise [InvalidSchema] if data is invalid
  def receivers
    raise InvalidSchema unless valid?

    @receivers ||= raw_data[:receivers].map do |receiver_data|
      build_receiver(receiver_data[:im], receiver_data[:identifier])
    end
  end

  private

  attr_reader :raw_data

  def schema_validator
    JSON::Validator
  end

  # rubocop:disable Metrics/MethodLength
  def schema
    {
      type: 'object',
      required: %i[message receivers send_at],
      properties: {
        message: { type: 'string' },
        send_at: { type: 'string', format: 'date-time' },
        receivers: {
          type: 'array',
          items:
            {
              type: 'object',
              required: %i[im identifier],
              properties: {
                im: { type: 'string' },
                identifier: { type: 'string' }
              }
            }
        }
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  def build_receiver(im, identifier)
    Receiver.new(im, identifier)
  end
end
