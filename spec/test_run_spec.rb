require 'spec_helper'

describe DatatrueClient::TestRun do
  before(:all) do
    require 'bridge_mock'
  end

  before(:each) do
    @test_run = DatatrueClient::TestRun.new({
      host: 'test.local',
      scheme: 'http',
      api_key: '_AHQZRHZ3kD0kpa0Al-SJg',

      test_run: {
        test_class: 'TestScenario',
        test_id: '1'
      },

      polling_interval: 0.1,
      polling_timeout: 1
    })
  end

  it 'sends a create test run request and sets job_id' do
    expect(@test_run.job_id).not_to be_nil
  end

  describe '#query_progress' do
    it 'returns progress of the test run' do
      expect(@test_run.query_progress[:progress][:percentage]).to be_a(Integer)
    end
  end

  describe '#poll_progress' do
    before(:each) do
    end

    it 'polls until test run is complete' do
      expect(@test_run.poll_progress[:status]).to eq('completed')
    end

    it 'timeout' do
      @test_run.polling_timeout = 0.1
      expect {@res = @test_run.poll_progress}.to raise_error(DatatrueClient::TimeoutError)
    end
  end
end
