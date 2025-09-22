module PoemGenerationConstants
  DEFAULTS = {
    cut_up: {
      num_lines: 12,
      words_per_line: 6
    },
    erasure: {
      num_pages: 3,
      words_per_page: 50,
      words_to_keep: 8,
      is_blackout: false
    },
    snowball: {
      num_lines: 10,
      min_word_length: 1
    },
    mesostic: {
      spine_word: ""
    },
    n_plus_seven: {
      offset: 7,
      words_to_select: 50
    },
    definitional: {
      section_length: 200,
      words_to_replace: 20
    },
    found: {
      num_lines: 10,
      line_length: "medium"
    },
    kwic: {
      num_lines: 10,
      context_window: 3,
      keyword: "",
      use_all_appearances: false
    },
    prisoners_constraint: {
      num_words: 20,
      constraint_type: "full_constraint"
    },
    beautiful_outlaw: {
      lines_per_stanza: 4,
      words_per_line: 6
    },
    lipogram: {
      num_words: 20,
      line_length: "medium",
      letter_to_omit: "e"
    }
  }.freeze

  VALIDATION = {
    minimum_words: 10,
    minimum_content_length: 100,
    minimum_word_length: 2,
    minimum_snowball_lines: 3,
    minimum_word_variety: 3,
    minimum_found_poem_words: 20,
    minimum_beautiful_outlaw_words: 15
  }.freeze

  TEXT_PROCESSING = {
    sentence_min_length: 10,
    sentence_min_words: 3,
    erasure_word_multiplier: 8
  }.freeze

  WORD_RANGES = {
    very_short: 1..2,
    short: 3..4,
    medium: 5..7,
    long: 8..10,
    very_long: 10..15
  }.freeze

  CUT_UP_RANGES = {
    3 => 3..4,
    6 => 5..8,
    10 => 8..12,
    15 => 12..18,
    default: 5..7
  }.freeze

  FOUND_POEM = {
    max_fallback_attempts: 50
  }.freeze

  PRISONERS_CONSTRAINT = {
    single_line_threshold: 3,
    line_length_probabilities: {
      single_word: { range: 0..40, length: 1 },
      two_words: { range: 41..70, length: 2 },
      three_words: { range: 71..90, length: 3 },
      four_words: { length: 4 }
    },
    random_max: 100
  }.freeze

  MODEL = {
    short_content_limit: 100
  }.freeze
end
