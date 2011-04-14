SpellCheck = Struct.new(:search, :dictionary) do
  def initialize(*args)
    super
    self.dictionary ||= []
  end

  def best_match
    dictionary.sort_by{|s| subsequence(s)}.last
  end

  def subsequence(word)
    word = word.split(//)
    search_split = search.split(//)

    total_sequence = {}
    search_split.each_with_index do |char,index|
      if char == word[index]
        total_sequence[char] ||= Set.new
        total_sequence[char] << index
      end
    end

    (1..search_split.size-1).each do |index|
      char = search_split[-index]
      if char == word[-index]
        total_sequence[char] ||= Set.new
        total_sequence[char] << search_split.size-index
      end
    end

    total_sequence.values.inject(0){|sum,count| sum + count.size}
  end

  def self.import(file_name='INPUT.txt')
    @@searches = [] 
    File.open(file_name) do |file|
      while !file.eof? do
        line = file.readline.chomp

        case
        when line =~ /^\d+$/
          @@max_searches = line.to_i
        when line.empty?
          next
        else
          spellcheck = self.new(line)
          2.times{spellcheck.dictionary << file.readline.chomp}
          @@searches << spellcheck
        end
      end
    end
    raise 'Wrong number of searches' unless  @@searches.count == @@max_searches
  end

  def self.searches
    @@searches
  end
end
