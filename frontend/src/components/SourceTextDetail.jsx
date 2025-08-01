import { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import { sourceTextsAPI, poemsAPI } from "../services/api";

function SourceTextDetail() {
  const { id } = useParams();
  const [sourceText, setSourceText] = useState(null);
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const [message, setMessage] = useState("");

  useEffect(() => {
    loadSourceText();
  }, [id]);

  const loadSourceText = async () => {
    try {
      const response = await sourceTextsAPI.getById(id);
      setSourceText(response.data);
    } catch (error) {
      console.error("Error loading source text:", error);
      setMessage("Error loading source text");
    } finally {
      setLoading(false);
    }
  };

  const handleGenerateCutUp = async () => {
    setGenerating(true);
    setMessage("");

    try {
      const response = await poemsAPI.generateCutUp(id);
      if (response.data.success) {
        setMessage(`Successfully generated "${response.data.poem.title}"!`);
        // Could redirect to the poem or refresh source text data
      }
    } catch (error) {
      setMessage(
        error.response?.data?.message || "Error generating cut-up poem"
      );
    } finally {
      setGenerating(false);
    }
  };

  if (loading) return <div className="loading">Loading...</div>;
  if (!sourceText) return <div className="error">Source text not found</div>;

  return (
    <div className="source-text-detail">
      <div className="header">
        <Link to="/source-texts" className="back-link">
          ← Back to Source Texts
        </Link>
        <div className="actions">
          <Link to="/poems" className="btn btn-secondary">
            View All Poems
          </Link>
          <button
            onClick={handleGenerateCutUp}
            disabled={generating}
            className="btn btn-primary"
          >
            {generating ? "Generating..." : "Generate Cut-Up Poem"}
          </button>
        </div>
      </div>

      <div className="text-info">
        <h1>{sourceText.title}</h1>

        <div className="metadata">
          <span className="word-count">
            {(sourceText.word_count || 0).toLocaleString()} words
          </span>
          {sourceText.gutenberg_id && (
            <span className="gutenberg-id">
              Project Gutenberg ID: {sourceText.gutenberg_id}
            </span>
          )}
          <span className="poems-count">
            {sourceText.poems_count} poems generated
          </span>
        </div>

        {message && (
          <div
            className={`message ${
              message.includes("Error") ? "error" : "success"
            }`}
          >
            {message}
          </div>
        )}
      </div>

      <div className="content">
        <h3>Content Preview</h3>
        <div className="text-content">
          {sourceText.content
            .split("\n\n")
            .slice(0, 10)
            .map((paragraph, index) => (
              <p key={index}>{paragraph}</p>
            ))}
          {sourceText.content.split("\n\n").length > 10 && (
            <p className="truncated">... (content truncated)</p>
          )}
        </div>
      </div>
    </div>
  );
}

export default SourceTextDetail;
