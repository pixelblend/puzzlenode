Flight = Struct.new(:departure, :arrival, :departure_time, :arrival_time, :price) do
  def self.import(file_name='input.txt')
    @@flights = []
    flight_set = []

    File.open(file_name) do |flight_file|
      while !flight_file.eof?
        line = flight_file.readline.chomp

        case
        when line.empty?
          next
        when line =~ /^\d$/
          @@flights << flight_set unless flight_set.empty?
          flight_set = []
        else
          flight_set << Flight.new(*line.split(' '))
        end
      end
    end
    @@flights << flight_set unless flight_set.empty?
  end

  def self.sets
    @@flights.size
  end

  def self.flights
    @@flights
  end

  def self.cheapest_for_set(set_num)
    routes = routed_flights_for_set(set_num)
    #order sets by total time / cost
    sorted_routes = routes.group_by{|rs| total_price_for_flights(rs)} 
    debugger
    formatted_route sorted_routes[sorted_routes.keys.last]
  end

  def self.fastest_for_set(set_num)
    raise 'not implemented'
    routes = routed_flights_for_set(set_num)
    #order sets by total time / cost
    sorted_routes = routes.group_by{|rs| rs.inject(0){|sum,f| sum + f.duration}}
    #debugger
    sorted_routes
  end

  def self.routed_flights_for_set(set_num)
    #look for starting points - A
    flight_set = flights[set_num-1]
    routes = []
    flight_set.select{|f| f.departure == 'A'}.each do |flight_a|
      route = []
      route << flight_a

      while route.last.arrival != 'Z'
        #collect potential next stages
        #departure must be after prev arrival
        next_steps = flight_set.select do |r| 
          r.departure == route.last.arrival \
            && r.arrival > route.last.departure \
            && r.departure_time > route.last.arrival_time
        end

        if next_steps.size == 1
          route += next_steps 
        else
          raise 'too many flights to choose from!'
        end
      end
      routes << route
    end
    routes
  end

  def self.formatted_route(flights)
    "#{flights.first.departure_time} #{flights.last.departure_time} #{total_cost_for_flights(flights)}"
  end

  def self.total_price_for_flights(flights)
    flights.inject(0.0){|sum,f| sum + f.price.to_f}
  end

  def duration
    debugger
    #load these as times and then calc distance
    #DateTime.parse
    self.arrival_time.split(':').first.to_i - self.departure_time.split(':').first.to_i
  end
end
