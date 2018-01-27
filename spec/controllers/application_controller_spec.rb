require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }
  let(:errors) { json_response[:errors] }
  let(:status) { response.status }

  before {
    # TODO: stub IMs here
  }

  after do # clear
    REDIS_POOL.with do |conn|
      conn.del :messages
    end
    # TODO: clear sidekiq
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

      it 'creates entity' do
        REDIS_POOL.with do |redis|
          expect do
            post :plan, params: { message: 'Hello there!', receivers: [{im: 'well_known', identifier: 'foo'}, {im: 'other', identifier: 'bar'}], send_at: '2018-03-05 12:44' }
          end.to change { redis.hlen(:messages) }.from(0).to(1)
        end
      end

      it 'creates tasks' do
        # post :plan, params: { message: 'Hello there!', receivers: [{im: 'well_known', identifier: 'foo'}, {im: 'other', identifier: 'bar'}], send_at: '2018-03-05 12:44' }

        # tasks = SendingWorker.tasks
        # expect(tasks.size).to eql(1)
        #
        # expect(tasks.first["at"]).to eql(1520243040.0) # Time.parse('2018-03-05 12:44').to_f
      end

    end
  end
end
