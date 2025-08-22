export const VALIDATION = {
  USERNAME: {
    MIN_LENGTH: 3,
    MAX_LENGTH: 30,
    PATTERN: "[a-zA-Z0-9_]+",
    TITLE: "Username can only contain letters, numbers, and underscores",
  },
  PASSWORD: {
    MIN_LENGTH: 6,
  },
  NAME: {
    MAX_LENGTH: 50,
  },
  BIO: {
    MAX_LENGTH: 500,
  },
};

export const POEM_GENERATION_DEFAULTS = {
  CUT_UP: {
    NUM_LINES: 12,
    WORDS_PER_LINE: 6,
  },
  ERASURE: {
    NUM_PAGES: 3,
    WORDS_PER_PAGE: 50,
    WORDS_TO_KEEP: 8,
    IS_BLACKOUT: false,
  },
  SNOWBALL: {
    NUM_LINES: 10,
    MIN_WORD_LENGTH: 1,
  },
  MESOSTIC: {
    SPINE_WORD: "",
  },
  N_PLUS_SEVEN: {
    OFFSET: 7,
    WORDS_TO_SELECT: 50,
  },
  DEFINITIONAL: {
    SECTION_LENGTH: 200,
    WORDS_TO_REPLACE: 20,
  },
  FOUND: {
    NUM_LINES: 10,
    LINE_LENGTH: "medium",
  },
  KWIC: {
    NUM_LINES: 10,
    CONTEXT_WINDOW: 3,
    KEYWORD: "",
  },
  PRISONERS_CONSTRAINT: {
    NUM_WORDS: 20,
    CONSTRAINT_TYPE: "full_constraint",
  },
};

export const INPUT_LIMITS = {
  NUM_LINES: { MIN: 1, MAX: 50 },
  WORDS_PER_LINE: { MIN: 1, MAX: 30 },
  NUM_PAGES: { MIN: 1, MAX: 10 },
  WORDS_PER_PAGE: { MIN: 10, MAX: 200 },
  WORDS_TO_KEEP: { MIN: 1, MAX: 50 },
  MIN_WORD_LENGTH: { MIN: 1, MAX: 30 },
  OFFSET: { MIN: 1, MAX: 10 },
  WORDS_TO_SELECT: { MIN: 1, MAX: 200 },
  SECTION_LENGTH: { MIN: 10, MAX: 1000 },
  WORDS_TO_REPLACE: { MIN: 10, MAX: 2000 },
  CONTEXT_WINDOW: { MIN: 1, MAX: 30 },
};

export const CONTENT_DISPLAY = {
  PREVIEW_LENGTH: 9990,
  PARAGRAPH_TRUNCATE_LENGTH: 500,
  POEM_TECHNIQUES: {
    CUT_UP: "cut_up",
    ERASURE: "erasure",
    SNOWBALL: "snowball",
    MESOSTIC: "mesostic",
    N_PLUS_SEVEN: "n_plus_seven",
    DEFINITIONAL: "definitional",
    FOUND: "found",
    KWIC: "kwic",
    PRISONERS_CONSTRAINT: "prisoners_constraint",
  },
  LINE_LENGTH_OPTIONS: {
    SHORT: "short",
    MEDIUM: "medium",
    LONG: "long",
  },
};
