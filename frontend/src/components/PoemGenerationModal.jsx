import { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { poemsAPI } from "../services/api";
import { POEM_GENERATION_DEFAULTS } from "../constants";
import PrivacyToggle from "./PrivacyToggle";

function PoemGenerationModal({ sourceText, isOpen, onClose, onSuccess, onPoemGenerated }) {
  const [technique, setTechnique] = useState("cut_up");
  const [isPublic, setIsPublic] = useState(false);
  const [numLines, setNumLines] = useState(POEM_GENERATION_DEFAULTS.CUT_UP.NUM_LINES);
  const [wordsPerLine, setWordsPerLine] = useState(POEM_GENERATION_DEFAULTS.CUT_UP.WORDS_PER_LINE);
  const [numPages, setNumPages] = useState(POEM_GENERATION_DEFAULTS.ERASURE.NUM_PAGES);
  const [wordsPerPage, setWordsPerPage] = useState(POEM_GENERATION_DEFAULTS.ERASURE.WORDS_PER_PAGE);
  const [wordsToKeep, setWordsToKeep] = useState(POEM_GENERATION_DEFAULTS.ERASURE.WORDS_TO_KEEP);
  const [isBlackout, setIsBlackout] = useState(POEM_GENERATION_DEFAULTS.ERASURE.IS_BLACKOUT);
  const [snowballLines, setSnowballLines] = useState(POEM_GENERATION_DEFAULTS.SNOWBALL.NUM_LINES);
  const [minWordLength, setMinWordLength] = useState(
    POEM_GENERATION_DEFAULTS.SNOWBALL.MIN_WORD_LENGTH
  );
  const [spineWord, setSpineWord] = useState(POEM_GENERATION_DEFAULTS.MESOSTIC.SPINE_WORD);
  const [offset, setOffset] = useState(POEM_GENERATION_DEFAULTS.N_PLUS_SEVEN.OFFSET);
  const [wordsToSelect, setWordsToSelect] = useState(
    POEM_GENERATION_DEFAULTS.N_PLUS_SEVEN.WORDS_TO_SELECT
  );
  const [sectionLength, setSectionLength] = useState(
    POEM_GENERATION_DEFAULTS.DEFINITIONAL.SECTION_LENGTH
  );
  const [wordsToReplace, setWordsToReplace] = useState(
    POEM_GENERATION_DEFAULTS.DEFINITIONAL.WORDS_TO_REPLACE
  );
  const [foundPoemLines, setFoundPoemLines] = useState(POEM_GENERATION_DEFAULTS.FOUND.NUM_LINES);
  const [lineLength, setLineLength] = useState(POEM_GENERATION_DEFAULTS.FOUND.LINE_LENGTH);
  const [keyword, setKeyword] = useState(POEM_GENERATION_DEFAULTS.KWIC.KEYWORD);
  const [kwicLines, setKwicLines] = useState(POEM_GENERATION_DEFAULTS.KWIC.NUM_LINES);
  const [contextWindow, setContextWindow] = useState(POEM_GENERATION_DEFAULTS.KWIC.CONTEXT_WINDOW);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState("");

  const handleGenerate = async (e) => {
    e.preventDefault();
    setGenerating(true);
    setError("");

    if (technique === "mesostic" && !spineWord.trim()) {
      setError("Spine word is required for mesostic poetry");
      setGenerating(false);
      return;
    }

    if (technique === "kwic" && !keyword.trim()) {
      setError("Keyword is required for KWIC poetry");
      setGenerating(false);
      return;
    }

    try {
      let options = { method: technique };

      switch (technique) {
        case "cut_up":
          options.num_lines = numLines;
          options.words_per_line = wordsPerLine;
          break;
        case "erasure":
          options.num_pages = numPages;
          options.words_per_page = wordsPerPage;
          options.words_to_keep = wordsToKeep;
          options.is_blackout = isBlackout;
          break;
        case "snowball":
          options.num_lines = snowballLines;
          options.min_word_length = minWordLength;
          break;
        case "mesostic":
          options.spine_word = spineWord;
          break;
        case "n_plus_seven":
          options.offset = offset;
          options.words_to_select = wordsToSelect;
          break;
        case "definitional":
          options.section_length = sectionLength;
          options.words_to_replace = wordsToReplace;
          break;
        case "found":
          options.num_lines = foundPoemLines;
          options.line_length = lineLength;
          break;
        case "kwic":
          options.keyword = keyword;
          options.num_lines = kwicLines;
          options.context_window = contextWindow;
          break;
      }

      options.is_public = isPublic;

      const response = await poemsAPI.generatePoem(sourceText.id, options);

      if (response.data.success) {
        onSuccess(response.data.message);
        onClose();

        if (onPoemGenerated && response.data.poem) onPoemGenerated(response.data.poem.id);
      }
    } catch (error) {
      setError(error.response?.data?.message || "Error generating poem");
    } finally {
      setGenerating(false);
    }
  };

  if (!isOpen) return null;

  const lineLengthOptions = [
    { value: "very_short", label: "Very Short (1-2 words)" },
    { value: "short", label: "Short (3-4 words)" },
    { value: "medium", label: "Medium (5-7 words)" },
    { value: "long", label: "Long (8-10 words)" },
    { value: "very_long", label: "Very Long (10-15 words)" },
  ];

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Generate Poem</h2>
          <button className="modal-close" onClick={onClose}>
            ×
          </button>
        </div>

        <div className="modal-body">
          <p className="source-info">
            From: <strong>{sourceText.title}</strong>
          </p>

          <form onSubmit={handleGenerate}>
            <div className="form-group">
              <label htmlFor="technique">Poetry Technique:</label>
              <select
                id="technique"
                value={technique}
                onChange={(e) => setTechnique(e.target.value)}
                disabled={generating}
              >
                <option value="cut_up">Cut-Up</option>
                <option value="erasure">Erasure</option>
                <option value="snowball">Snowball</option>
                <option value="mesostic">Mesostic</option>
                <option value="n_plus_seven">N+7</option>
                <option value="definitional">Definitional</option>
                <option value="found">Found</option>
                <option value="kwic">KWIC (KeyWord In Context)</option>
              </select>
            </div>

            {technique === "cut_up" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    Cut-up poetry randomly selects and rearranges words from the source text to
                    create new verse combinations. This technique, popularized by William S.
                    Burroughs, generates unexpected juxtapositions and fresh meanings.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="num-lines">Number of Lines:</label>
                  <input
                    type="number"
                    id="num-lines"
                    value={numLines}
                    onChange={(e) => setNumLines(parseInt(e.target.value) || 0)}
                    min="1"
                    max="50"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="words-per-line">Words Per Line:</label>
                  <input
                    type="number"
                    id="words-per-line"
                    value={wordsPerLine}
                    onChange={(e) => setWordsPerLine(parseInt(e.target.value) || 0)}
                    min="1"
                    max="30"
                    disabled={generating}
                  />
                </div>
              </>
            )}

            {technique === "erasure" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    Erasure poetry removes most words from existing text, leaving behind only select
                    words that form new poems. Blackout style visually shows the erased words as
                    solid blocks, mimicking the original erasure technique of marking out text with
                    black ink.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="num-pages">Number of Pages:</label>
                  <input
                    type="number"
                    id="num-pages"
                    value={numPages}
                    onChange={(e) => setNumPages(parseInt(e.target.value) || 0)}
                    min="1"
                    max="10"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="words-per-page">Words Per Page:</label>
                  <input
                    type="number"
                    id="words-per-page"
                    value={wordsPerPage}
                    onChange={(e) => setWordsPerPage(parseInt(e.target.value) || 0)}
                    min="10"
                    max="200"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="words-to-keep">Words to Keep Per Page:</label>
                  <input
                    type="number"
                    id="words-to-keep"
                    value={wordsToKeep}
                    onChange={(e) => setWordsToKeep(parseInt(e.target.value) || 0)}
                    min="1"
                    max="50"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label className="checkbox-label">
                    <input
                      type="checkbox"
                      checked={isBlackout}
                      onChange={(e) => setIsBlackout(e.target.checked)}
                      disabled={generating}
                    />
                    <span className="checkbox-text">
                      Use blackout style (█ blocks instead of spaces)
                    </span>
                  </label>
                </div>
              </>
            )}

            {technique === "snowball" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    Snowball poems start with a word of your chosen length and each subsequent line
                    contains a word that's one character longer. Perfect for creating poems with a
                    sense of building momentum and growth.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="snowball-lines">Number of Lines:</label>
                  <input
                    type="number"
                    id="snowball-lines"
                    value={snowballLines}
                    onChange={(e) => setSnowballLines(parseInt(e.target.value) || 0)}
                    min="1"
                    max="30"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="min-word-length">Starting Word Length (characters):</label>
                  <input
                    type="number"
                    id="min-word-length"
                    value={minWordLength}
                    onChange={(e) => setMinWordLength(parseInt(e.target.value) || 0)}
                    min="1"
                    max="10"
                    disabled={generating}
                  />
                </div>
              </>
            )}

            {technique === "mesostic" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    Mesostic poetry uses a "spine word" to guide the poem's structure. Each line
                    contains a word from the source text that has the corresponding letter of the
                    spine word in the correct position. For example, with spine word "dog", the
                    first line will contain a word with 'd' as the first letter, the second line
                    with 'o' as the second letter, and the third line with 'g' as the third letter.
                    Use spaces in your spine word to create multiple stanzas. For example, "dog cat"
                    will create two stanzas - one for "dog" and one for "cat", separated by a blank
                    line.
                  </p>
                </div>
                <div className="form-group">
                  <label htmlFor="spine-word">Spine Word (Required):</label>
                  <input
                    type="text"
                    id="spine-word"
                    value={spineWord}
                    onChange={(e) => setSpineWord(e.target.value)}
                    placeholder="Enter a word (e.g., 'dog', 'poetry')"
                    disabled={generating}
                    required
                  />
                </div>
              </>
            )}

            {technique === "n_plus_seven" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    N+7 poetry replaces nouns in the source text with the 7th (or your chosen
                    offset) noun that appears after them in the dictionary. This technique,
                    developed by the Oulipo group, creates surprising juxtapositions while
                    maintaining the original text's grammatical structure. The algorithm randomly
                    selects a subset of words from your source text and applies N+7 replacement to
                    all nouns found in that selection, creating new meanings and unexpected
                    connections.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="offset">Dictionary Offset:</label>
                  <input
                    type="number"
                    id="offset"
                    value={offset}
                    onChange={(e) => setOffset(parseInt(e.target.value) || 0)}
                    min="1"
                    max="200"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="words-to-select">Words to Select:</label>
                  <input
                    type="number"
                    id="words-to-select"
                    value={wordsToSelect}
                    onChange={(e) => setWordsToSelect(parseInt(e.target.value) || 0)}
                    min="10"
                    max="1000"
                    disabled={generating}
                  />
                </div>
              </>
            )}

            {technique === "definitional" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    Definitional literature replaces words in the source text with their dictionary
                    definitions. First, a section of text is selected based on your chosen length.
                    Then, within that section, a specified number of words are randomly chosen and
                    replaced with their dictionary definitions. This technique creates new meanings
                    by expanding simple words into their full definitions, often revealing hidden
                    layers of meaning and creating unexpected juxtapositions.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="section-length">Section Length:</label>
                  <input
                    type="number"
                    id="section-length"
                    value={sectionLength}
                    onChange={(e) => {
                      const newValue = parseInt(e.target.value) || 0;
                      setSectionLength(newValue);
                      if (wordsToReplace >= newValue) {
                        setWordsToReplace(Math.max(1, Math.floor(newValue * 0.1)));
                      }
                    }}
                    min="10"
                    max="2000"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="words-to-replace">Words to Replace:</label>
                  <input
                    type="number"
                    id="words-to-replace"
                    value={wordsToReplace}
                    onChange={(e) => {
                      const newValue = parseInt(e.target.value) || 0;
                      if (newValue >= sectionLength) {
                        setError("Words to replace must be less than section length");
                        return;
                      }
                      setError("");
                      setWordsToReplace(newValue);
                    }}
                    min="1"
                    max={Math.min(1999, sectionLength - 1)}
                    disabled={generating}
                  />
                  {wordsToReplace >= sectionLength && (
                    <div className="message error">
                      Words to replace must be less than section length
                    </div>
                  )}
                </div>
              </>
            )}

            {technique === "found" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    Found poetry extracts consecutive lines from different sections of the source
                    text. Each line is taken from a different part of the book to ensure diversity,
                    while maintaining the natural flow of consecutive words within each line. This
                    technique creates new meaning by recontextualizing existing text fragments,
                    allowing the original work to speak in new and unexpected ways.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="found-poem-lines">Number of Lines:</label>
                  <input
                    type="number"
                    id="found-poem-lines"
                    value={foundPoemLines}
                    onChange={(e) => setFoundPoemLines(parseInt(e.target.value) || 0)}
                    min="1"
                    max="30"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="line-length">Length of Lines:</label>
                  <select
                    id="line-length"
                    value={lineLength}
                    onChange={(e) => setLineLength(e.target.value)}
                    disabled={generating}
                  >
                    {lineLengthOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>
              </>
            )}

            {technique === "kwic" && (
              <>
                <div className="form-description">
                  <p className="technique-description">
                    KWIC (KeyWord In Context) poetry creates a poem by finding all instances of a
                    chosen keyword in the source text and displaying each occurrence with its
                    surrounding context. Each line shows the keyword with a few words before and
                    after it, creating a unique perspective on how that word is used throughout the
                    text.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="keyword">Keyword (Required):</label>
                  <input
                    type="text"
                    id="keyword"
                    value={keyword}
                    onChange={(e) => setKeyword(e.target.value)}
                    placeholder="Enter a keyword (e.g., 'love', 'wind', 'heart')"
                    disabled={generating}
                    required
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="kwic-lines">Number of Lines:</label>
                  <input
                    type="number"
                    id="kwic-lines"
                    value={kwicLines}
                    onChange={(e) => setKwicLines(parseInt(e.target.value) || 0)}
                    min="1"
                    max="30"
                    disabled={generating}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="context-window">Context Window (words on each side):</label>
                  <input
                    type="number"
                    id="context-window"
                    value={contextWindow}
                    onChange={(e) => setContextWindow(parseInt(e.target.value) || 0)}
                    min="1"
                    max="10"
                    disabled={generating}
                  />
                </div>
              </>
            )}

            <PrivacyToggle
              isPublic={isPublic}
              onChange={setIsPublic}
              disabled={generating}
              contentType="poem"
            />

            {error && <div className="message error">{error}</div>}

            <div className="modal-actions">
              <button
                type="button"
                onClick={onClose}
                className="btn btn-secondary"
                disabled={generating}
              >
                Cancel
              </button>
              <button type="submit" className="btn btn-primary" disabled={generating}>
                {generating ? "Generating..." : "Generate Poem"}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default PoemGenerationModal;
