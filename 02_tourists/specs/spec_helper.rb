require 'bundler/setup'
require 'rspec'

require 'ruby-debug'

APP_ROOT = File.dirname(__FILE__)+'/../'

require APP_ROOT+'/lib/flight'
require APP_ROOT+'/lib/tourist'

module MockHelper
  def mock_files
		@flight_file = APP_ROOT+'samples/sample-input.txt'
  end
end
