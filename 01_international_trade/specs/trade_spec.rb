require 'bundler/setup'
require 'rspec'

require 'ruby-debug'

APP_ROOT = File.dirname(__FILE__)+'/../'

require APP_ROOT+'/lib/trade'

module TradeHelper
  def mock_files
    trans = File.read(APP_ROOT+'samples/SAMPLE_TRANS.csv')
    rates = File.read(APP_ROOT+'samples/SAMPLE_RATES.xml')
    IO.should_receive(:read).with('TRANS.csv', nil, nil) {trans}
    File.should_receive(:read).with('RATES.xml') {StringIO.open rates}
  end
end


describe Trade do
  include TradeHelper

  before do
    mock_files
    @trade = Trade.new
  end

  it 'should load rates' do
    @trade.should have(3).rates
  end

  it 'should have rates with accurate attributes' do
    rate = @trade.rates.first
    rate.source.should == 'AUD'
    rate.destination.should == 'CAD'
    rate.amount.should == 1.0079
  end

  it 'should load transactions' do
    @trade.should have(5).transactions
  end

  it 'should have transactions with accurate attributes' do
    trans = @trade.transactions.first
    trans.store.should  == 'Yonkers'
    trans.item.should == 'DM1210'
    trans.amount.should == 70.00
    trans.currency.should == 'USD'
  end

  it 'should calculate total sales for a given item' do
    @trade.total_sales('DM1182').to_f.to_s.should == BigDecimal.new('134.22').to_f.to_s
  end
end
