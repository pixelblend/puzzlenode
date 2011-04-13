require File.dirname(__FILE__)+'/spec_helper'

describe Flight do
  include MockHelper

  before do
    mock_files
    Flight.import(@flight_file)
  end

  it "should import 2 sets of flights" do
    Flight.sets.should == 2
  end

  it "should have 3 flights in set 1" do
    Flight.flights[0].should have(3).things
  end

  it "should have 7 flights in set 2" do
    Flight.flights[1].should have(7).things
    #Flight.set_2.should have(7).things
  end

  it "should parse flight data correctly" do
    first_flight = Flight.flights.flatten.first

    first_flight.departure.should == 'A'
    first_flight.arrival.should == 'B'
    first_flight.departure_time.should == '09:00'
    first_flight.arrival_time.should  == '10:00'
    first_flight.price.should == '100.00'
  end

  it 'should find the fastest route for set 1' do
    Flight.fastest_for_set(1).to_s.should == '09:00 13:30 200.00'
  end

  it 'should find the cheapest route for set 1' do
    Flight.cheapest_for_set(1).to_s.should == '10:00 12:00 300.00'
  end
end
