module ElasticsearchQueryParser
  # Transform user query to `Left to Right` expression for parser usage
  class Sentence
    attr_reader :sentence
    private :sentence

    # Split by whitespace, but not split words in quotes
    WORD_SPLITTER_REGEX = /(?:'(?:\\.|[^'])*'|[^' ])+/.freeze

    # Initialize with user input
    def initialize(sentence)
      @sentence = sentence
    end

    # Return valid for parser usage user input
    # Example:
    #   >> ElasticsearchQueryParser.new("(London AND Madrid) OR Paris").to_s
    #   => "Paris OR ( Madrid AND London )"
    def to_s
      left_to_right? ? sentence : revert_left_to_right
    end

    private

    def revert_left_to_right
      prepared_sentence.scan(WORD_SPLITTER_REGEX).reverse.map do |word|
        if word == "("
          ")"
        elsif word == ")"
          "("
        else
          word
        end
      end.join(" ")
    end

    # Left to Right expresstion starts with simple term instead of expression
    def left_to_right?
      return true unless sentence

      sentence[0] != "("
    end

    # Add whitespace before/after parentheses
    def prepared_sentence
      if sentence
        sentence.split("").reduce("") do |left_to_right_string, char|
          left_to_right_string + (["(", ")"].include?(char) ? " #{char} " : char)
        end
      else
        ""
      end
    end
  end
end
