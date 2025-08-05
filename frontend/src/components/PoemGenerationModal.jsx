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
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState("");

  const handleGenerate = async (e) => {
    e.preventDefault();
    setGenerating(true);
    setError("");

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
        });
      }

      if (response.data.success) {
        onSuccess(response.data.message);
        onClose();

        if (onPoemGenerated && response.data.poem) {
          onPoemGenerated(response.data.poem.id);
        }
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
