import { useState } from "react";
import { poemsAPI } from "../services/api";

function PoemGenerationModal({
  sourceText,
  isOpen,
  onClose,
  onSuccess,
  onPoemGenerated,
}) {
  const [numLines, setNumLines] = useState(12);
  const [wordsPerLine, setWordsPerLine] = useState(6);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState("");

  const handleGenerate = async (e) => {
    e.preventDefault();
    setGenerating(true);
    setError("");

    try {
      const response = await poemsAPI.generateCutUp(sourceText.id, {
        method: "cut_up",
        num_lines: numLines,
        words_per_line: wordsPerLine,
      });
      if (response.data.success) {
        onSuccess(response.data.message);
        onClose();
        // Navigate to the generated poem
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
    {
      value: 16,
      label: "16 lines",
    },
    { value: 20, label: "20 lines" },
  ];

  const wordOptions = [
    {
      value: 3,
      label: "3-4 words",
    },
    { value: 6, label: "5-7 words" },
    {
      value: 10,
      label: "8-12 words",
    },
    {
      value: 15,
      label: "12-18 words",
    },
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
              <label htmlFor="poem-type">Poem Type:</label>
              <div className="poem-type-display">
                <strong>Cut-Up Poetry</strong>
                <p className="help-text">
                  Randomly selects and rearranges words from the source text to
                  create experimental poetry
                </p>
              </div>
            </div>

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
