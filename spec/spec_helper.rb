require 'guard'
require 'rspec'

ENV['GUARD_ENV'] = 'test'

RSpec.configure do |config|
  config.order = :random
  config.filter_run focus: ENV['CI'] != 'true'
  config.run_all_when_everything_filtered = true
  config.raise_errors_for_deprecations!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
