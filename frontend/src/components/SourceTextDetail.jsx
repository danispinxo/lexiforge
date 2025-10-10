import { useState, useEffect, useCallback } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { CONTENT_DISPLAY } from "../constants";
import { sourceTextsAPI } from "../services/api";
import PoemGenerationModal from "./PoemGenerationModal";
import { useAuth } from "../hooks/useAuth";

function SourceTextDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [sourceText, setSourceText] = useState(null);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
  const [showModal, setShowModal] = useState(false);

  const loadSourceText = useCallback(async () => {
    try {
      const response = await sourceTextsAPI.getById(id);
      setSourceText(response.data);
    } catch {
      setMessage("Error loading source text");
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    loadSourceText();
  }, [loadSourceText]);

  const handlePoemGenerated = (successMessage) => {
    setMessage(successMessage);
    loadSourceText();
  };

  const handleNavigateToPoem = (poemId) => navigate(`/poems/${poemId}`);

  const handleDownload = async () => {
    if (!user) {
      setMessage("You must be logged in to download source texts");
      return;
    }

    try {
      const response = await sourceTextsAPI.download(id);
      const blob = new Blob([response.data], { type: "text/plain" });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `${sourceText.title}.txt`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);

      setMessage("Source text downloaded successfully!");
    } catch {
      setMessage("Error downloading source text");
    }
  };

  if (loading) return <div className="loading">Loading...</div>;
  if (!sourceText) return <div className="error">Source text not found</div>;

  return (
    <div className="source-text-detail">
      <div className="header">
        <Link to="/source-texts" className="back-link">
          Back to All Public Source Texts
        </Link>
        <div className="actions">
          {user ? (
            <>
              {(user.admin || user.user_type === "admin") && (
                <Link to={`/source-texts/${id}/edit`} className="btn btn-secondary">
                  Edit Source Text
                </Link>
              )}
              <button onClick={() => setShowModal(true)} className="btn btn-primary">
                Generate Poem
              </button>
              <button onClick={handleDownload} className="btn btn-primary">
                Download as TXT
              </button>
            </>
          ) : (
            <div className="auth-required-message">
              <Link to="/login" className="btn btn-secondary">
                Log in to Generate Poems
              </Link>
            </div>
          )}
        </div>
      </div>

      <div className="text-info">
        <h1>{sourceText.title}</h1>

        <div className="metadata">
          <span className="word-count">{(sourceText.word_count || 0).toLocaleString()} words</span>
          {sourceText.gutenberg_id && (
            <span className="gutenberg-id">Project Gutenberg ID: {sourceText.gutenberg_id}</span>
          )}
          <span className="poems-count">{sourceText.poems_count} poems generated</span>
        </div>

        {message && (
          <div className={`message ${message.includes("Error") ? "error" : "success"}`}>
            {message}
          </div>
        )}
      </div>

      <div className="content">
        <h3>Content Preview</h3>
        <div className="text-content">
          {(() => {
            const truncatedText =
              sourceText.content.substring(0, CONTENT_DISPLAY.PREVIEW_LENGTH) + "...";
            let paragraphs = truncatedText.split("\n\n");

            if (paragraphs.length === 1) {
              paragraphs = truncatedText.split("\n").filter((p) => p.trim().length > 0);
            }

            if (paragraphs.length === 1) {
              paragraphs = truncatedText.split(/\.\s+(?=[A-Z])/).map((p) => p + ".");
            }

            return paragraphs.map((paragraph, index) => {
              const cleanParagraph = paragraph.trim();
              const truncatedParagraph =
                cleanParagraph.length > CONTENT_DISPLAY.PARAGRAPH_TRUNCATE_LENGTH
                  ? cleanParagraph.substring(0, CONTENT_DISPLAY.PARAGRAPH_TRUNCATE_LENGTH) + "..."
                  : cleanParagraph;
              return <p key={index}>{truncatedParagraph}</p>;
            });
          })()}
          <p className="truncated">... (content preview truncated)</p>
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
