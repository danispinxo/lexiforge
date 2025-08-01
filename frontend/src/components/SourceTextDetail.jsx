import { useState, useEffect } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { sourceTextsAPI } from "../services/api";
import PoemGenerationModal from "./PoemGenerationModal";

function SourceTextDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [sourceText, setSourceText] = useState(null);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
  const [showModal, setShowModal] = useState(false);

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

  const handlePoemGenerated = (successMessage) => {
    setMessage(successMessage);
    loadSourceText();
  };

  const handleNavigateToPoem = (poemId) => {
    navigate(`/poems/${poemId}`);
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
            onClick={() => setShowModal(true)}
            className="btn btn-primary"
          >
            Generate Poem
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

      <PoemGenerationModal
        sourceText={sourceText}
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        onSuccess={handlePoemGenerated}
        onPoemGenerated={handleNavigateToPoem}
      />
    </div>
  );
}

export default SourceTextDetail;
