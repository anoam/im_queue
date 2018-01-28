require 'rails_helper'
RSpec.describe SendingWorker, type: :worker do
  subject { SendingWorker.new }
  let(:result) { double(success?: true) }

  before do
    allow(SendingService).to receive(:call).and_return(result)
  end

  it 'calls sending service' do
    expect(SendingService).to receive(:call).with('im1', 'id1', 'Hello!')
    subject.perform('im1', 'id1', 'Hello!')
  end

  it 'calls sending service again' do
    expect(SendingService).to receive(:call).with('im2', '42', 'Hi!')
    subject.perform('im2', '42', 'Hi!')
  end

  it 'raises error when service failed' do
    allow(result).to receive(:success?).and_return(false)

    expect { subject.perform('im1', 'id1', 'Hello!') }
        .to raise_error(SendingWorker::UnableToSendError)
  end

end
