# DataTrue API client

DataTrue is a SaaS platform to audit, monitor and validate tags, dataLayers and data collected from websites. The [DataTrue Test Builder chrome extension](https://chrome.google.com/webstore/detail/datatrue-test-builder/oghoceohpfhokhcoomihkobmpbcljall?hl=en) can quickly create test interactions with websites using our library of 100+ tag templates or custom tags. DataTrue works across complex AJAX interactions (e.g. using [AngularJS](https://angularjs.org/)), iframe content and multiple domains.

This ruby client allows you to trigger DataTrue tests from a Continuous Integration tool such as [Jenkins](https://jenkins.io/), [Teamcity](https://www.jetbrains.com/teamcity/), [Travis CI](https://travis-ci.org/), [Codeship](https://codeship.com/) and others.  If you’re practicing Continuous Delivery, it can be used to trigger a test of your application as soon as changes are released.

## Table of Contents

- [DataTrue API client](#datatrue-api-client)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Command-line usage](#command-line-usage)
      - [Environment variables](#environment-variables)
    - [Usage in a Ruby application](#usage-in-a-ruby-application)
  - [Support](#support)
  - [Contributing](#contributing)
    - [Development](#development)
  - [License](#license)

## Usage

You will need a DataTrue account ([free sign-up](https://datatrue.com/?utm_source=github&utm_medium=listing&utm_campaign=API_Client)) to use this gem.  To get your API key go to the [Accounts page](https://datatrue.com/accounts/?utm_source=github&utm_medium=listing&utm_campaign=API_Client), select your account and click on "Generate API Key".

The next steps assume you have a test suite created in DataTrue.  Read our [Knowledge Base](https://support.datatrue.com/hc/en-us/categories/200080049-Knowledge-Base?utm_source=github&utm_medium=listing&utm_campaign=API_Client) to find-out [how to quickly create a single-page test](https://support.datatrue.com/hc/en-us/articles/213538568-1-Use-Quick-Start-to-create-a-single-page-test?utm_source=github&utm_medium=listing&utm_campaign=API_Client).

Install the gem on the system you want to trigger your tests from:

```bash
$ gem install datatrue_client
```

Alternatively, if you want to include the client as part of your ruby application, you can add this line to your Gemfile:

```ruby
gem 'datatrue_client', :group => [:test, :development]
```

### Command-line usage

Use the following CLI syntax to select your test(s) or test suite along with other options.

```bash
$ datatrue_client run 1539 -a rtTlaqucG9RrTg1G2L1O0u -t suite \
    -v HOSTNAME=datatrue.com,GTMID=GTM-ABCXYZ \
    -e 543,544

datatrue_client: job=5e9316aa116b4a6fe5dfebda68accd60 created for test="DataTrue Public pages"
datatrue_client: test_run_id=52454 step=1 total_steps=7 result=running
datatrue_client: test_run_id=52454 step=1 total_steps=7 result=passed
...
datatrue_client: test_run_id=52454 step=7 total_steps=7 result=passed
datatrue_client: test_run_id=52454 finished result=passed.
```

The exit status of the application will change according to test results:

- `0`: test run successful, result=passed.
- `1`: test run successful, result=failed.
- `-1`: generic test run error. See output detail.
- `-2`: authentication or authorisation error.  Check your API key and test identifiers.
- `-3`: quota exceeded.  You have used-up all your subscription allowance for this period.

If you want to ignore the exit status, use the shell's `||` operator; e.g.: `datatrue_client [options] || true`.  This will ensure that the exit status is always `0`.

`datatrue_client <command> [command-arguments] -a <api_key> [command-options]`

_Commands_:

- `run`: triggers a new run of tests or a test suite and waits for it to finish.

```text
datatrue_client run <suite_id | test_id_1,test_id_2,...> -a <api_key>
    [-t | --type=suite|test] [-v | --variables foo=bar,thunder=flash]
    [-e | --email-users '1,2,3...'] [-s | --silent]
```

- `trigger`: triggers a new run of tests or a test suite and exits immediately.

```text
datatrue_client trigger <suite_id | test_id_1,test_id_2,...> -a <api_key>
    [-t | --type=suite|test] [-v | --variables foo=bar,thunder=flash]
    [-s | --silent]
```

_Options_:

- `-a` or `--api-key`: The DataTrue API key. Overrides the API key provided as an environment variable.
- `-t` or `--type`: The type of test to be run. Valid options are `test` or `suite`.
- `-v` or `--variables`: Variables provided to the test. These can be used to change behaviour of your test, provide credentials and more.
- `-e` or `--email-users`: Comma-separated list of user identifiers who will receive an email with the test results.
- `-s` or `--silent`: Suppress all application output.
- `-h` or `--help`: Show help message.

_Specific options for run_:

- `--timeout`: Time to wait before the run finishes.

#### Environment variables

- `DATATRUE_API_KEY`: your DataTrue API key.  The `-a` option takes precedence.

### Usage in a Ruby application

Trigger a test run:

```ruby
test_run = DatatrueClient::TestRun.new({
  host: 'localhost:3000',
  scheme: 'http',
  api_key: '_AHQZRHZ3kD0kpa0Al-SJg',  # please remember to generate your own key on datatrue.com

  test_run: {
    test_class: 'TestScenario',
    test_id: 1
  },
  variables: {
    key: value
  },

  polling_interval: 2,  # in seconds, 2 by default
  polling_timeout: 120  # in seconds, 60 by default
})
```

Query progress:

```ruby
test_run.query_progress

# returns the progress hash
#
# {
#   time: 1463359905,
#   status: "working",
#   uuid: "a1f7868b1db44d38c16585ce37e4ac3f",
#   num: 4,
#   total: 5,
#   progress: {
#     percentage: 80,
#     tests: [
#       {
#         id: 1,
#         name: "Test name",
#         state: "running",
#         steps_completed: 4,
#         steps: [
#           {
#             name: "Step name",
#             running: false,
#             pending: false,
#             error: nil,
#             tags: [
#               { name: "Tag name', enabled: true, valid: true },
#               ...
#             ]
#           },
#           ...
#         ]
#       },
#       ...
#     ]
#   }
# }
```

Poll progress (blocks until the run is finished or timed out):

```ruby
test_run.poll_progress
```

## Support

Our [support website](https://support.datatrue.com/?utm_source=github&utm_medium=listing&utm_campaign=API_Client) has more detailed information about DataTrue and the API client.

If you believe you have found a bug, please [reach-out using the support website](https://support.datatrue.com/hc/en-us/requests/new?utm_source=github&utm_medium=listing&utm_campaign=API_Client) or through support@datatrue.com.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/Lens10/datatrue-api-client>.

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
