require 'scrapers'
require 'webmock/rspec'
require 'vcr'
require 'rspec/its'
require 'database_cleaner'
require 'pathname'
require 'dotenv'
require 'timecop'
require 'byebug'

Dotenv.load

Dir[Scrapers::ROOT.join("spec/support/**/*.rb")].each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Migration.verbose = false
Scrapers::Benchmarks::Migration.new.migrate(:up)
Scrapers::Steam::Migration.new.migrate(:up)

# Add a custom logger for debugging
LL = begin
  logfile = File.open("#{Scrapers::ROOT}/log/custom.log", 'a')  # create log file
  logfile.sync = true  # automatically flushes data to file
  Scrapers::CustomLogger.new(logfile)  # constant accessible anywhere
end

define_method :L, &LL.method(:l)
define_method :LA, &LL.method(:la)
define_method :LN, &LL.method(:ln)

VCR.configure do |config|
  config.ignore_request do |request|
    URI(request.uri).host == '127.0.0.1'
  end

  # This is so we can read the response body text and
  # maybe touch it a little for edge cases
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' ||
    !http_message.body.valid_encoding?
  end

  config.cassette_library_dir = "#{Scrapers::ROOT}/spec/fixtures/vcr_cassettes"
  config.hook_into :typhoeus
  config.configure_rspec_metadata!
end

VCR_OPTIONS = {
  record: :new_episodes,
  preserve_exact_body_bytes: true,
  match_requests_on: [:method, :uri, :body]
}

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include SteamListSpecHelpers, type: :steam_list
  config.include ProcessorSpecHelper

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # config.backtrace_exclusion_patterns << /\/gems\//

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each, js: true do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  def cassette_name(file_path, name)
    path = file_path.gsub(/^\.\/spec\/|_spec\.rb$/, '').split(File::SEPARATOR)
    path.push(name) unless name === true
    path.join('/')
  end

  config.around :example do |example|
    cassette = example.metadata[:cassette]

    if cassette
      path = cassette_name(example.file_path, cassette)

      VCR.use_cassette(path, VCR_OPTIONS) do
        example.run
      end
    else
      example.run
    end
  end

  def before_all_cassette(name = true, &block)
    path = cassette_name(file_path, name)

    before :all do
      VCR.use_cassette(path, VCR_OPTIONS) do
        self.instance_eval(&block)
      end
    end
  end

  def response_json
    JSON.parse(response.body)
  end

  def stub_url(url, status, body, headers = {})
    Typhoeus.stub(url).and_return(Typhoeus::Response.new(code: status, body: body, headers: headers))
  end
end
