import { useState } from "react";
import { poemsAPI } from "../services/api";

function PoemGenerationModal({
  sourceText,
  isOpen,
  onClose,
  onSuccess,
  onPoemGenerated,
}) {
  const [technique, setTechnique] = useState("cut_up");
  const [numLines, setNumLines] = useState(12);
  const [wordsPerLine, setWordsPerLine] = useState(6);
  const [numPages, setNumPages] = useState(3);
  const [wordsPerPage, setWordsPerPage] = useState(50);
  const [wordsToKeep, setWordsToKeep] = useState(8);
  const [isBlackout, setIsBlackout] = useState(false);
  const [snowballLines, setSnowballLines] = useState(10);
  const [minWordLength, setMinWordLength] = useState(1);
  const [spineWord, setSpineWord] = useState("");
  const [offset, setOffset] = useState(7);
  const [wordsToSelect, setWordsToSelect] = useState(50);
  const [sectionLength, setSectionLength] = useState(200);
  const [wordsToReplace, setWordsToReplace] = useState(20);
  const [foundPoemLines, setFoundPoemLines] = useState(10);
  const [lineLength, setLineLength] = useState("medium");
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

    try {
      let response;
      if (technique === "cut_up") {
        response = await poemsAPI.generateCutUp(sourceText.id, {
          method: "cut_up",
          num_lines: numLines,
          words_per_line: wordsPerLine,
        });
      } else if (technique === "erasure") {
        response = await poemsAPI.generateErasure(sourceText.id, {
          method: "erasure",
          num_pages: numPages,
          words_per_page: wordsPerPage,
          words_to_keep: wordsToKeep,
          is_blackout: isBlackout,
        });
      } else if (technique === "snowball") {
        response = await poemsAPI.generateSnowball(sourceText.id, {
          method: "snowball",
          num_lines: snowballLines,
          min_word_length: minWordLength,
        });
      } else if (technique === "mesostic") {
        response = await poemsAPI.generateMesostic(sourceText.id, {
          method: "mesostic",
          spine_word: spineWord,
        });
      } else if (technique === "n_plus_seven") {
        response = await poemsAPI.generateNPlusSeven(sourceText.id, {
          method: "n_plus_seven",
          offset: offset,
          words_to_select: wordsToSelect,
        });
      } else if (technique === "definitional") {
        response = await poemsAPI.generateDefinitional(sourceText.id, {
          method: "definitional",
          section_length: sectionLength,
          words_to_replace: wordsToReplace,
        });
      } else if (technique === "found_poem") {
        response = await poemsAPI.generateFoundPoem(sourceText.id, {
          method: "found_poem",
          num_lines: foundPoemLines,
          line_length: lineLength,
        });
      }

      if (response.data.success) {
        onSuccess(response.data.message);
        onClose();

        if (onPoemGenerated && response.data.poem)
          onPoemGenerated(response.data.poem.id);
      }
    } catch (error) {
      setError(error.response?.data?.message || "Error generating poem");
    } finally {
      setGenerating(false);
    }
  };

  if (!isOpen) return null;

  const lineOptions = [
    { value: 6, label: "6 lines" },
    { value: 8, label: "8 lines" },
    { value: 12, label: "12 lines" },
    { value: 16, label: "16 lines" },
    { value: 20, label: "20 lines" },
  ];

  const wordOptions = [
    { value: 3, label: "3-4 words" },
    { value: 6, label: "5-7 words" },
    { value: 10, label: "8-12 words" },
    { value: 15, label: "12-18 words" },
  ];

  const pageOptions = [
    { value: 1, label: "1 page" },
    { value: 2, label: "2 pages" },
    { value: 3, label: "3 pages" },
    { value: 4, label: "4 pages" },
    { value: 5, label: "5 pages" },
  ];

  const wordsPerPageOptions = [
    { value: 30, label: "30 words" },
    { value: 50, label: "50 words" },
    { value: 75, label: "75 words" },
    { value: 100, label: "100 words" },
  ];

  const wordsToKeepOptions = [
    { value: 5, label: "5 words" },
    { value: 8, label: "8 words" },
    { value: 12, label: "12 words" },
    { value: 15, label: "15 words" },
    { value: 20, label: "20 words" },
  ];

  const snowballLineOptions = [
    { value: 5, label: "5 lines" },
    { value: 8, label: "8 lines" },
    { value: 10, label: "10 lines" },
    { value: 12, label: "12 lines" },
    { value: 15, label: "15 lines" },
    { value: 20, label: "20 lines" },
  ];

  const minWordLengthOptions = [
    { value: 1, label: "1 character" },
    { value: 2, label: "2 characters" },
    { value: 3, label: "3 characters" },
    { value: 4, label: "4 characters" },
    { value: 5, label: "5 characters" },
  ];

  const offsetOptions = [
    { value: 3, label: "3 words ahead" },
    { value: 5, label: "5 words ahead" },
    { value: 7, label: "7 words ahead" },
    { value: 10, label: "10 words ahead" },
    { value: 15, label: "15 words ahead" },
  ];

  const wordsToSelectOptions = [
    { value: 25, label: "25 words" },
    { value: 50, label: "50 words" },
    { value: 75, label: "75 words" },
    { value: 100, label: "100 words" },
    { value: 150, label: "150 words" },
  ];

  const sectionLengthOptions = [
    { value: 100, label: "100 words" },
    { value: 200, label: "200 words" },
    { value: 300, label: "300 words" },
    { value: 500, label: "500 words" },
    { value: 1000, label: "1000 words" },
  ];

  const wordsToReplaceOptions = [
    { value: 10, label: "10 words" },
    { value: 20, label: "20 words" },
    { value: 30, label: "30 words" },
    { value: 50, label: "50 words" },
    { value: 100, label: "100 words" },
  ];

  const foundPoemLineOptions = [
    { value: 5, label: "5 lines" },
    { value: 8, label: "8 lines" },
    { value: 10, label: "10 lines" },
    { value: 12, label: "12 lines" },
    { value: 15, label: "15 lines" },
    { value: 20, label: "20 lines" },
  ];

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
                <option value="cut_up">Cut-Up Poetry</option>
                <option value="erasure">Erasure Poetry</option>
                <option value="snowball">Snowball Poetry</option>
                <option value="mesostic">Mesostic Poetry</option>
                <option value="n_plus_seven">N+7 Poetry</option>
                <option value="definitional">Definitional Literature</option>
                <option value="found_poem">Found Poetry</option>
              </select>
            </div>

            {technique === "cut_up" && (
              <>
                <div className="form-group">
                  <label htmlFor="num-lines">Number of Lines:</label>
                  <select
                    id="num-lines"
                    value={numLines}
                    onChange={(e) => setNumLines(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {lineOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label htmlFor="words-per-line">Words Per Line:</label>
                  <select
                    id="words-per-line"
                    value={wordsPerLine}
                    onChange={(e) => setWordsPerLine(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {wordOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-description">
                  <p className="technique-description">
                    Cut-up poetry randomly selects and rearranges words from the
                    source text to create new verse combinations. This
                    technique, popularized by William S. Burroughs, generates
                    unexpected juxtapositions and fresh meanings.
                  </p>
                </div>
              </>
            )}

            {technique === "erasure" && (
              <>
                <div className="form-group">
                  <label htmlFor="num-pages">Number of Pages:</label>
                  <select
                    id="num-pages"
                    value={numPages}
                    onChange={(e) => setNumPages(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {pageOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label htmlFor="words-per-page">Words Per Page:</label>
                  <select
                    id="words-per-page"
                    value={wordsPerPage}
                    onChange={(e) => setWordsPerPage(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {wordsPerPageOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label htmlFor="words-to-keep">Words to Keep Per Page:</label>
                  <select
                    id="words-to-keep"
                    value={wordsToKeep}
                    onChange={(e) => setWordsToKeep(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {wordsToKeepOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
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

                <div className="form-description">
                  <p className="technique-description">
                    Erasure poetry removes most words from existing text,
                    leaving behind only select words that form new poems.
                    Blackout style visually shows the erased words as solid
                    blocks, mimicking the original erasure technique of marking
                    out text with black ink.
                  </p>
                </div>
              </>
            )}

            {technique === "snowball" && (
              <>
                <div className="form-group">
                  <label htmlFor="snowball-lines">Number of Lines:</label>
                  <select
                    id="snowball-lines"
                    value={snowballLines}
                    onChange={(e) => setSnowballLines(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {snowballLineOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label htmlFor="min-word-length">Starting Word Length:</label>
                  <select
                    id="min-word-length"
                    value={minWordLength}
                    onChange={(e) => setMinWordLength(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {minWordLengthOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-description">
                  <p className="technique-description">
                    Snowball poems start with a word of your chosen length and
                    each subsequent line contains a word that's one character
                    longer. Perfect for creating poems with a sense of building
                    momentum and growth.
                  </p>
                </div>
              </>
            )}

            {technique === "mesostic" && (
              <>
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

                <div className="form-description">
                  <p className="technique-description">
                    Mesostic poetry uses a "spine word" to guide the poem's
                    structure. Each line contains a word from the source text
                    that has the corresponding letter of the spine word in the
                    correct position. For example, with spine word "dog", the
                    first line will contain a word with 'd' as the first letter,
                    the second line with 'o' as the second letter, and the third
                    line with 'g' as the third letter.
                    <br />
                    <br />
                    <strong>Stanza breaks:</strong> Use spaces in your spine
                    word to create multiple stanzas. For example, "dog cat" will
                    create two stanzas - one for "dog" and one for "cat",
                    separated by a blank line.
                  </p>
                </div>
              </>
            )}

            {technique === "n_plus_seven" && (
              <>
                <div className="form-group">
                  <label htmlFor="offset">Dictionary Offset:</label>
                  <select
                    id="offset"
                    value={offset}
                    onChange={(e) => setOffset(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {offsetOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label htmlFor="words-to-select">Words to Select:</label>
                  <select
                    id="words-to-select"
                    value={wordsToSelect}
                    onChange={(e) => setWordsToSelect(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {wordsToSelectOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-description">
                  <p className="technique-description">
                    N+7 poetry replaces nouns in the source text with the 7th
                    (or your chosen offset) noun that appears after them in the
                    dictionary. This technique, developed by the Oulipo group,
                    creates surprising juxtapositions while maintaining the
                    original text's grammatical structure. The algorithm
                    randomly selects a subset of words from your source text and
                    applies N+7 replacement to all nouns found in that
                    selection, creating new meanings and unexpected connections.
                  </p>
                </div>
              </>
            )}

            {technique === "definitional" && (
              <>
                <div className="form-group">
                  <label htmlFor="section-length">Section Length:</label>
                  <select
                    id="section-length"
                    value={sectionLength}
                    onChange={(e) => setSectionLength(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {sectionLengthOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label htmlFor="words-to-replace">Words to Replace:</label>
                  <select
                    id="words-to-replace"
                    value={wordsToReplace}
                    onChange={(e) =>
                      setWordsToReplace(parseInt(e.target.value))
                    }
                    disabled={generating}
                  >
                    {wordsToReplaceOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-description">
                  <p className="technique-description">
                    Definitional literature replaces words in the source text
                    with their dictionary definitions. First, a section of text
                    is selected based on your chosen length. Then, within that
                    section, a specified number of words are randomly chosen and
                    replaced with their dictionary definitions. This technique
                    creates new meanings by expanding simple words into their
                    full definitions, often revealing hidden layers of meaning
                    and creating unexpected juxtapositions.
                  </p>
                </div>
              </>
            )}

            {technique === "found_poem" && (
              <>
                <div className="form-group">
                  <label htmlFor="found-poem-lines">Number of Lines:</label>
                  <select
                    id="found-poem-lines"
                    value={foundPoemLines}
                    onChange={(e) => setFoundPoemLines(parseInt(e.target.value))}
                    disabled={generating}
                  >
                    {foundPoemLineOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
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

                <div className="form-description">
                  <p className="technique-description">
                    Found poetry extracts consecutive lines from different sections of the source text. 
                    Each line is taken from a different part of the book to ensure diversity, while 
                    maintaining the natural flow of consecutive words within each line. This technique 
                    creates new meaning by recontextualizing existing text fragments, allowing the 
                    original work to speak in new and unexpected ways.
                  </p>
                </div>
              </>
            )}

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
              <button
                type="submit"
                className="btn btn-primary"
                disabled={generating}
              >
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
