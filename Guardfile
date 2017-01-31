guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || "spec/acceptance"
  end
  watch(%r{^lib/scrapers/oculus/page_processor\.rb$}){ 'spec/scrapers/oculus' }
  watch(%r{^lib/scrapers/oculus/schema\.json$}){ 'spec/scrapers/oculus' }
  watch(%r{^lib/scrapers/steam/game/schema\.json$}){ 'spec/scrapers/steam/game' }
  watch(%r{^lib/scrapers/steam/list/schema\.json$}){ 'spec/scrapers/steam/list' }
  watch(%r{^lib/scrapers/steam/reviews/schema\.json$}){ 'spec/scrapers/steam/reviews' }
end
