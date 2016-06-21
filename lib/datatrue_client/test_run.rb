require "datatrue_client/bridge"

module DatatrueClient
  class TimeoutError < StandardError; end
  class QuotaExceeded < StandardError; end

  class TestRun
    attr_reader :job_id, :title, :progress
    attr_accessor :polling_timeout, :polling_interval

    # @param options [Hash]
    #   options = {
    #     polling_interval: 0.1,
    #     polling_timeout: 1
    #   }
    #   options will also be passed to `Bridge.new` and `Bridge#create_test_run`,
    #   see `Bridge` for other possible option keys
    def initialize(options={})
      @options = options
      @bridge = Bridge.new(options)

      @polling_timeout = options[:polling_timeout] || 60
      @polling_interval = options[:polling_interval] || 2

      create
    end

    # Queries test run progress
    # @return [Hash] data about progress
    def query_progress
      @bridge.test_run_progress(job_id)
    end

    # Keeps querying progress until progress status is `complete`
    # @param print_progress [Proc] called with current progress percentage and details
    def poll_progress(print_progress=nil)
      start_time = DateTime.now

      loop do
        res = query_progress
        @progress = progress_percentage(res)
        print_progress.call(@progress, res) if print_progress

        return res if res[:status] == 'completed'

        if elapsed_milliseconds(start_time, DateTime.now) >= @polling_timeout * 1000
          raise TimeoutError.new("Polling progress timed out after #{@polling_timeout} seconds")

          break
        else
          sleep @polling_interval
        end
      end
    end

    private

    def create
      res = @bridge.create_test_run(@options)
      @job_id = res[:job_id]
      @title = res[:title]
    end

    def progress_percentage(progress_res)
      if progress_res[:status] == 'queued'
        0
      elsif progress_res[:status] == 'completed'
        raise QuotaExceeded.new(progress_res[:error]) if progress_res[:error]
        100
      else
        progress_res[:progress].nil? ? 0 : progress_res[:progress][:percentage]
      end
    end

    def elapsed_milliseconds(start_time, end_time)
      ((end_time - start_time) * 24 * 60 * 60 * 1000).to_i
    end
  end
end
