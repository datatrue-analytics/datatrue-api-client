require 'addressable/uri'
require 'rest-client'
require 'json'

module DatatrueClient

  # Abstracts HTTP details of DataTrueClient commands, all methods are synchronous
  class Bridge
    attr_accessor :host, :scheme

    def initialize(options={})
      @host = options[:host] || 'datatrue.com'
      @scheme = options[:scheme] || 'https'
      @api_key = options[:api_key]
    end

    # Creates and queues a DataTrue test run
    # @param payload [Hash]
    #   payload = {
    #     test_run: {
    #       test_class: 'TestScenario',
    #       test_id: '1',
    #       email_users: [1, ...]
    #     },
    #     variables: {
    #       name: value,
    #       ...
    #     }
    #   }
    # @return [Hash] data about created test run, including job_id
    def create_test_run(payload)
      post("test_runs", payload)
    end

    # Queries test run progress
    # @param job_id [String] test run job id
    # @return [Hash] data about progress
    #   {
    #     time: 1463359905,
    #     status: "working",
    #     uuid: "a1f7868b1db44d38c16585ce37e4ac3f",
    #     num: 4,
    #     total: 5,
    #     progress: {
    #       percentage: 80,
    #       tests: [
    #         {
    #           id: 1,
    #           name: "Test name",
    #           state: "running",
    #           steps_completed: 4,
    #           steps: [
    #             {
    #               name: "Step name",
    #               running: false,
    #               pending: false,
    #               error: nil,
    #               tags: [
    #                 { name: "Tag name', enabled: true, valid: true },
    #                 ...
    #               ]
    #             },
    #             ...
    #           ]
    #         },
    #         ...
    #       ]
    #     }
    #   }
    def test_run_progress(job_id)
      get("test_runs/progress/#{job_id}")
    end

    private

    def url(path)
      Addressable::URI.parse("#{scheme}://#{host}/ci_api/#{path}?api_key=#{@api_key}").normalize.to_str
    end

    # Sends a GET request to url(path)
    # @param path [String] the request path
    # @return [Hash] parsed response body as a hash
    def get(path)
      parse_response RestClient.get(url(path), { accept: :json })
    end

    # Sends a POST request to url(path)
    # @param path [String] the request path
    # @param payload [Hash] data which will be converted to json and send in request body
    # @return [Hash] parsed response body as a hash
    def post(path, payload)
      res = RestClient.post url(path), payload.to_json, { content_type: :json, accept: :json }
      parse_response(res)
    end

    # Parses json string to a hash and tries to convert keys to symbols
    # @param res [String] RestClient response / json string
    # @return [Hash] parsed hash
    def parse_response(res)
      hash = JSON.parse(res)

      # convert keys to symbols
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end

      hash
    end

  end
end
