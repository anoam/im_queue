require 'rails_helper'

RSpec.describe SendingService do
  let(:messenger_1) { double }
  let(:messenger_2) { double }

  before do
    allow_any_instance_of(ImCollection).to receive(:messenger).and_return(nil)
    allow_any_instance_of(ImCollection).to receive(:messenger).with('well_known').and_return(messenger_1)
    allow_any_instance_of(ImCollection).to receive(:messenger).with('other').and_return(messenger_2)

    allow(messenger_1).to receive(:send_message).and_return(true)
    allow(messenger_2).to receive(:send_message).and_return(true)
    allow(messenger_1).to receive(:send_message).with('trouble_identifier', 'trouble_message').and_return(false)
  end

  it 'sends via messenger' do
    expect(messenger_1).to receive(:send_message).with('identity1', 'Hello')
    SendingService.call('well_known', 'identity1', 'Hello')
  end

  it 'sends via another messenger' do
    expect(messenger_2).to receive(:send_message).with('identity2', 'Hi!')
    SendingService.call('other', 'identity2', 'Hi!')
  end

  it 'successful when sending is successful' do
    result = SendingService.call('other', 'identity1', 'Hello')
    expect(result.success?).to be_truthy
  end

  it 'not successful when sending fails' do
    result = SendingService.call('well_known', 'trouble_identifier', 'trouble_message')
    expect(result.success?).to be_falsey
  end
end
