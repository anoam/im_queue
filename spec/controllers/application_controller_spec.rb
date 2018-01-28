require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }
  let(:errors) { json_response[:errors] }
  let(:status) { response.status }

  before do
    messenger_1 = double
    messenger_2 = double

    allow_any_instance_of(ImCollection).to receive(:messenger).and_return(nil)
    allow_any_instance_of(ImCollection).to receive(:messenger).with('well_known').and_return(messenger_1)
    allow_any_instance_of(ImCollection).to receive(:messenger).with('other').and_return(messenger_2)

    allow(messenger_1).to receive(:identifier_valid?).and_return(true)
    allow(messenger_2).to receive(:identifier_valid?).and_return(true)
    allow(messenger_1).to receive(:identifier_valid?).with('invalid_identifier').and_return(false)
  end

  after do # clear
    # SendingWorker.jobs.clear
  end

  describe '#POST plan' do

    it 'fails on empty parameters' do
      post :plan
      expect(errors).to include('invalid data')
      expect(status).to eql(400)
    end

    it 'fails on invalid' do
      post :plan, params: { foo: "bar", baz: "fizz" }

      expect(errors).to include('invalid data')
      expect(status).to eql(400)
    end

    context 'when params are inconsistent' do

      it 'fails on unknown IM' do
        post :plan, params: { message: 'My message', receivers: [{im: 'weired', identifier: 'foo'}], send_at: '2018-03-05 12:44' }

        expect(errors).to include('invalid IM')
        expect(status).to eql(422)
      end

      it 'fails on empty message' do
        post :plan, params: { message: '', receivers: [{im: 'well_known', identifier: 'foo'}], send_at: '2018-03-05 12:44' }

        expect(errors).to include('invalid messsage')
        expect(status).to eql(422)
      end

      it 'fails on invalid identifier' do
        post :plan, params: { message: 'Hello there!', receivers: [{im: 'well_known', identifier: 'invalid_identifier'}, {im: 'other', identifier: 'foo'}], send_at: '2018-03-05 12:44' }

        expect(errors).to include('invalid identifier')
        expect(status).to eql(422)
      end

      it 'fails on invalid send time' do
        post :plan, params: { message: 'Hello there!', receivers: [{im: 'well_known', identifier: 'foo'}, {im: 'other', identifier: 'bar'}], send_at: 'not a time' }

        expect(errors).to include('invalid send time')
        expect(status).to eql(422)
      end
    end

    context 'whe params valid' do

      it 'response with ok' do
        post :plan, params: { message: 'Hello there!', receivers: [{im: 'well_known', identifier: 'foo'}, {im: 'other', identifier: 'bar'}], send_at: '2018-03-05 12:44' }

        expect(status).to eql(200)
        expect(json_response[:success]).to be_truthy
      end

      it 'creates tasks' do
        # post :plan, params: { message: 'Hello there!', receivers: [{im: 'well_known', identifier: 'foo'}, {im: 'other', identifier: 'bar'}], send_at: '2018-03-05 12:44' }

        # tasks = SendingWorker.jobs
        # expect(tasks.size).to eql(2)
        #
        # expect(tasks.first["at"]).to eql(1520243040.0) # Time.parse('2018-03-05 12:44').to_f
        # expect(tasks.first["args"]).to eql(['other', 'foo', 'Hello there!'])
        # expect(tasks.second["at"]).to eql(1520243040.0) # Time.parse('2018-03-05 12:44').to_f
        # expect(tasks.second["args"]).to eql(['other', 'bar', 'Hello there!'])
      end

    end
  end
end
