require 'spec_helper'

describe DatatrueClient::Bridge do
  before(:each) do
    @bridge = DatatrueClient::Bridge.new host: 'test.local', scheme: 'http'
  end

  after(:each) do
    WebMock.reset!
  end

  describe '#create_test_run' do
    before(:each) do
      @stub = stub_request(:post, /.*\/test_runs/)
        .to_return(body: {job_id: 1}.to_json)

      @res = @bridge.create_test_run({
        test_run: {
          test_class: 'TestScenario',
          test_id: '1'
        }
      })
    end

    it 'sends request to create test run' do
      expect(@stub).to have_been_requested
    end

    it 'returns hash with created job_id' do
      expect(@res).to be_a(Hash)
      expect(@res[:job_id]).not_to be_nil
    end
  end

  describe '#test_run_progress' do
    before(:each) do
      @stub = stub_request(:get, /.*\/test_runs\/progress\/.+$/)
        .to_return(body: {}.to_json)

      @res = @bridge.test_run_progress("1")
    end

    it 'sends request to query progress' do
      expect(@stub).to have_been_requested
    end
  end
end
