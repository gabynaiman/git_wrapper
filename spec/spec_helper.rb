require 'git_wrapper'

include GitWrapper
include GitWrapper::Results

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

end