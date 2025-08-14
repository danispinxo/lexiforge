namespace :dictionary do
  desc 'Populate dictionary_words table with WordNet data'
  task populate: :environment do
    puts 'Starting WordNet dictionary population...'

    require 'wordnet'

    puts 'WordNet loaded successfully'

    batch_size = 100
    processed_count = 0
    total_words = 0

    begin
      WordNet::Lexicon.new
      words = WordNet::Word.all
      total_words = words.count
      puts "Total words to process: #{total_words}"

      words.each_slice(batch_size) do |word_batch|
        ActiveRecord::Base.transaction do
          word_batch.each_with_index do |word, _batch_index|
            processed_count += 1

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
          end
        end

        puts "Processed #{processed_count}/#{total_words} words " \
             "(#{(processed_count.to_f / total_words * 100).round(1)}%)"

        if ((processed_count / batch_size) % 5).zero?
          GC.start
          puts "Memory cleanup performed at #{processed_count} words"
        end

        sleep(0.1)
      end
    rescue StandardError => e
      puts "Error during processing: #{e.message}"
      puts "Processed #{processed_count} words before error"
      raise e
    end

    puts 'WordNet dictionary population complete!'
    puts "Total dictionary words: #{DictionaryWord.count}"
  end
end
