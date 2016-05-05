module DatatrueClient

  class Bridge
    attr_accessor :host, :scheme

    def initialize(options={})
      @host = options[:host] || 'datatrue.com'
      @scheme = options[:scheme] || 'https'
      @progress = 0
    end

    def create_test_run(payload)
      {job_id: 1}
    end

    def test_run_progress(job_id)
      if @progress < 100
        res = {
          status: 'working',
          progress: {
            percentage: @progress
          }
        }

        @progress += 20
      else
        res = {
          status: 'completed'
        }
      end

      res
    end

  end
end
