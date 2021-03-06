require 'coverage_helper'
require 'git_wrapper'

include GitWrapper
include GitWrapper::Results

GitWrapper.logger.level = Logger::Severity::ERROR

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include DateHelper
end