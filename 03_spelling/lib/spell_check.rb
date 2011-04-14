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

    total_sequence = 0

#    #create search chunk from spelling (smallest first)
#    (0..search_split.size-1).each do |l_index|
#      #total_sequence = chunk if included in spelling
#      (1..search_split.size).each do |r_index|
#        search_chunk=search_split[l_index..-r_index].to_s
#        next if search_chunk.empty?
#        puts search_chunk
#        if word.include?(search_chunk)
#          total_sequence = search_chunk.size if search_chunk.size > total_sequence
#        end
#      end
#    end
#
#    (0..search_split.size-1).each do |l_index|
#      #total_sequence = chunk if included in spelling
#      (1..search_split.size).each do |r_index|
#        #puts search_chunk.to_s
#        search_chunk=search_split[l_index..-r_index]
#        if word.reverse.include?(search_chunk)
#          total_sequence = search_chunk.size if search_chunk.size > total_seqeunce
#        end
#      end
#    end

    word.each_with_index do |char,index|
      if char == search_split[index]
        total_sequence += 1
      end
    end

    word.reverse.each_with_index do |char,index|
      if char == search_split.reverse[index]
        total_sequence += 1
      end
    end
    total_sequence
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
