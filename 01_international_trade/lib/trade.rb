require 'bigdecimal'
require 'rexml/document'
require 'csv'

ROOT = File.dirname(__FILE__)+'/../'

class Trade
  class Rate
    attr_accessor :source, :destination, :amount
    def initialize(source, destination, amount)
      self.source = source
      self.destination = destination
      self.amount = BigDecimal.new amount
    end
  end

  class Transaction
    attr_accessor :store, :item, :amount, :currency
    def initialize(store, item, amount)
      self.store  = store
      self.item   = item
      self.amount, self.currency = amount.split(' ')

      self.amount = BigDecimal.new self.amount
    end
  end

  attr_accessor :rates, :transactions

  def initialize
    @rates = import_rates
    @transactions = import_transactions
  end

  def total_sales(item, currency='USD')
    #select sales for item
    sales = transactions.select{|t| t.item == item}

    sales.inject(BigDecimal('0.00')) do |sum,t|
      #convert to currency
      converted_sale = convert(t.amount, t.currency, currency)
      sum += converted_sale.bankers_round
    end
  end

  def convert(amount, source, destination)
    return amount if source == destination

    positive_rate = @rates.select do |r|
      r.source == source && r.destination == destination
    end.first

    if positive_rate
      return (amount * positive_rate.amount)
    end

    negative_rate = @rates.select do |r|
      r.source == destination && r.destination == source
    end.first

    if negative_rate
      return (amount / negative_rate.amount)
    end

    begin
      mid_rate = @rates.select{|r| r.source == source}.first
      end_rate = @rates.select{|r| r.source == mid_rate.destination && r.destination == destination}.first

      return (amount * mid_rate.amount * end_rate.amount)
    rescue
      raise "Nothing found for #{source} => #{destination }"
    end
  end

  private

  def import_transactions
    trade_csv = CSV.read('TRANS.csv')
    trade_csv.shift #header-be-gone
    trade_csv.collect {|row| Transaction.new(*row)}
  end

  def import_rates
    rates_xml = REXML::Document.new(File.read('RATES.xml'))

    rates_xml.elements.collect('rates/rate') do |rate|
      Rate.new *rate.elements.collect(&:text)
    end
  end
end

class BigDecimal
  def bankers_round
    self.round(2, ROUND_HALF_EVEN)
  end
end
