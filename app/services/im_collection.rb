# actually just fake. According problem, should work with fake messengers.
class ImCollection
  FakeMessenger = Struct.new(:name) do
    def identifier_valid?(identifier)
      return identifier != '' && identifier != 'invalid_identifier'
    end
  end

  def messenger(name)
    messengers.find { |messenger| messenger.name == name }
  end

  private

  def messengers
    @messengers ||= [FakeMessenger.new('im1'), FakeMessenger.new('im2')]
  end

end
