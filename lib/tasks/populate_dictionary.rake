namespace :dictionary do
  desc 'Populate dictionary_words table with WordNet data'
  task populate: :environment do
    puts 'Starting WordNet dictionary population...'

    require 'wordnet'

    puts 'WordNet loaded successfully'

    WordNet::Lexicon.new
    words = WordNet::Word.all
    puts "Available words: #{words.count}"

    words.each_with_index do |word, index|
      next if word.lemma.match?(/\s|\d/) || word.lemma.start_with?("'")
      
      synsets = word.synsets

      synsets.each do |synset|
        DictionaryWord.find_or_create_by(
          word: word.lemma.downcase,
          part_of_speech: synset.pos
        ) do |dw|
          dw.definition = synset.definition
          dw.synsets = synset.words.map(&:lemma)
        end
      end

      puts "Processed #{index + 1} words..." if ((index + 1) % 1000).zero?
    rescue StandardError => e
      puts "Error processing word #{index + 1}: #{e.message}"
    end

    puts 'WordNet dictionary population complete!'
    puts "Total dictionary words: #{DictionaryWord.count}"
  end
end
