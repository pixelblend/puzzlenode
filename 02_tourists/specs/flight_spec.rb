require 'bundler/setup'
require 'rspec'

require 'ruby-debug'

APP_ROOT = File.dirname(__FILE__)+'/../'

require APP_ROOT+'/lib/flight'

module FlightHelper
  def mock_files
		flights = File.read(APP_ROOT+'samples/sample-input.txt')
    File.should_receive(:read).with('input.txt') {StringIO.open flights}
  end
end

describe Flight do
  include FlightHelper

  before do
    mock_files
    @trade = Flight.new
  end
end
