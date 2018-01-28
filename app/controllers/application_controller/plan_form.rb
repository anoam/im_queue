class ApplicationController::PlanForm

  InvalidSchema = Class.new(StandardError)
  Receiver = Struct.new(:im, :identifier)

  def initialize(raw_data)
    @raw_data ||= raw_data
  end

  def valid?
    schema_validator.validate(schema, raw_data)
  end

  def message
    raise InvalidSchema unless valid?
    raw_data[:message]
  end

  def send_at
    raise InvalidSchema unless valid?

    @send_at ||= Time.parse(raw_data[:send_at])
  end

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

  def schema
    {
      type: 'object',
      required: %i(message receivers send_at),
      properties: {
        message: { type: 'string' },
        send_at: { type: 'string', format: 'date-time' },
        receivers: {
          type: 'array',
          items:
            {
              type: 'object',
              required: %i(im identifier),
              properties: {
                  im: { type: 'string' },
                  identifier: { type: 'string' }
              }
            }
        }
      }
    }
  end

  def build_receiver(im, identifier)
    Receiver.new(im, identifier)
  end
end
