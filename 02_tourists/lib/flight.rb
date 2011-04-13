require 'time'
Flight = Struct.new(:departure, :arrival, :departure_time, :arrival_time, :price) do
  FlightSet = Struct.new(:duration, :price, :flights, :depart, :arrive) do
    def initialize(*args)
      super
      self.duration = 0
      self.price    = 0.0
      self.flights = []
    end

    def <<(flight)
      self.depart ||= flight.departure_time
      self.arrive = flight.arrival_time
      self.price += flight.price.to_f
      self.duration += flight.duration
      self.flights << flight
    end

    def method_missing(method, *args)
      if flights.respond_to?(method)
        flights.send(method, *args) 
      else
        super
      end
    end

    def initialize_copy(original)
      super
      self.flights = original.flights.clone
    end
  end

  def self.import(file_name='input.txt')
    @@flights = []
    flight_set = []

    File.open(file_name) do |flight_file|
      while !flight_file.eof?
        line = flight_file.readline.chomp
        case
        when line.empty?
          next
        when line =~ /^\d+$/
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
    sorted_routes = routes.sort_by{|rs| rs.price} 
    formatted_route sorted_routes.first
  end

  def self.fastest_for_set(set_num)
    routes = routed_flights_for_set(set_num)
    sorted_routes = routes.sort_by{|rs| rs.duration}
    formatted_route sorted_routes.first
  end

  def self.routed_flights_for_set(set_num)
    @@routed_flights ||= []

    #look for starting points - A
    @flight_set = flights[set_num-1]
    routes = []

    @flight_set.select{|f| f.departure == 'A'}.each do |flight_a|
      route = FlightSet.new 
      route << flight_a

      all_routes = plot_flight_route(route)

      all_routes = [all_routes] unless all_routes.is_a?(Array)

      routes += all_routes
    end
    @@routed_flights[set_num-1] = routes.compact
  end


  def self.plot_flight_route(route)
    while route.last.arrival != 'Z'
      #collect potential next stages
      #departure must be after prev arrival
      next_steps = @flight_set.select do |r| 
        r.departure == route.last.arrival \
          && r.arrival != route.last.departure \
          && r.departure_time > route.last.arrival_time
      end

      case next_steps.size
      when 0
        break
      when 1
        route << next_steps.first
      else
        next_routes= next_steps.collect do |flight|
          clone_route = route.dup
          clone_route << flight
          plot_flight_route(clone_route)
        end
        return next_routes
      end
    end
    return route
  end

  def self.formatted_route(flight_set)
    "#{flight_set.depart} #{flight_set.arrive} #{flight_set.price}0"
  end

  def duration
    #in minutes
    ((Time.parse(arrival_time) - Time.parse(departure_time)).abs/60).round
  end
end
