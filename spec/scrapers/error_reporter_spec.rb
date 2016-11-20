require 'yaml'

describe Scrapers::ErrorReporter do
  def create_error_report(options)
    stub_url('http://www.example.com/hey?t=1', 403, '<html>Boo</html>', 'hello' => 'There')
    response = Typhoeus.get('http://www.example.com/hey?t=1', headers: { 'potato' => 'Salad' })

    # This is so it has a natural backtrace
    scrap_error = nil
    begin
      raise Scrapers::Errors::LoadingError.new("You can't look at that mate", response)
    rescue Scrapers::Errors::LoadingError => e
      scrap_error = e
    end

    scrap_abort_error = Scrapers::Errors::ScrapAbortError.new(scrap_error)
    reporter = Scrapers::ErrorReporter.new(scrap_abort_error, 'potato', filesystem: 'tmp/log/scrap_errors')
    reporter.commit
    @commit_time = Time.now
  end

  def match_report(report, html)
    expect(html).to eq '<html>Boo</html>'
    expect(report[:url]).to eq 'http://www.example.com/hey?t=1'
    expect(report[:code]).to eq 403
    expect(report[:time]).to be_within(1.second).of(@commit_time)
    expect(report[:message]).to eq "You can't look at that mate"
    expect(report[:backtrace]).to match(/error_reporter_spec\.rb/)
    expect(report[:request_headers].keys).to include('potato', 'User-Agent')
    expect(report[:response_headers].keys).to include('hello')
  end

  it 'should save a report and HTML file to the disk' do
    create_error_report(filesystem: 'tmp/log/scrap_errors', email: nil)

    file_name = @commit_time.strftime('%Y%m%d-%H%M%S') + '_potato_www_example_com_hey'
    yml_file_path = "#{Scrapers.app_root}/tmp/log/scrap_errors/#{file_name}.yml"
    html_file_path = "#{Scrapers.app_root}/tmp/log/scrap_errors/#{file_name}.html"

    expect(File.exist? yml_file_path).to eq true
    expect(File.exist? html_file_path).to eq true

    report = YAML.load_file(yml_file_path)
    html = File.read(html_file_path)

    match_report(report, html)
  end

  it 'should send an email with the report on the body and the attached HTML document' do
    create_error_report(filesystem: nil, email: 'zequez@gmail.com')

    # Yeah, not really sure how this will work, I'll do it later.
  end
end
