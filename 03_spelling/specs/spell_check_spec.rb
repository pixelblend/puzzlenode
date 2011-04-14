require File.dirname(__FILE__)+'/../lib/spell_check'
require 'ruby-debug'

describe SpellCheck do
  before do
    SpellCheck.import(File.dirname(__FILE__)+'/../samples/SAMPLE_INPUT.txt')
  end

  it 'should import searches' do
    SpellCheck.searches.should have(2).things
  end

  it 'should set correct attibutes for searches' do
    spelling = SpellCheck.searches.first
    spelling.search.should == 'remimance'
    spelling.dictionary.should == %w{remembrance reminiscence}
  end

  it 'should have the best spelling for "numm"' do
    spelling = SpellCheck.new("numm", ["nom", "numb"])
    spelling.best_match.should == "numb"
  end

  it 'should have the best spelling for "remimance"' do
    spelling = SpellCheck.searches[0]
    spelling.best_match.should == 'remembrance'
  end

  it 'should have the best spelling for "inndietlly"' do
    spelling = SpellCheck.searches[1]
    spelling.best_match.should == 'incidentally'
  end
end
