import { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faFileText,
  faDownload,
  faPlus,
  faCheckCircle,
  faExclamationTriangle,
  faLock,
  faGlobe,
  faTimes,
} from "../config/fontawesome";
import { sourceTextsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";

function SourceTextImportModal({ isOpen, onClose, onSuccess }) {
  const [gutenbergId, setGutenbergId] = useState("");
  const [isPublic, setIsPublic] = useState(true);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const { user } = useAuth();

  const handleImport = async (e) => {
    e.preventDefault();
    if (!gutenbergId) return;

    setLoading(true);
    setMessage("");

    try {
      const response = await sourceTextsAPI.importFromGutenberg(gutenbergId, isPublic);
      if (response.data.success) {
        setMessage(`Successfully imported "${response.data.source_text.title}"`);
        setGutenbergId("");
        setTimeout(() => {
          onSuccess(response.data.message);
          onClose();
          setMessage("");
        }, 1500);
      } else {
        setMessage(response.data.message || "Failed to import text");
      }
    } catch (error) {
      const errorMessage =
        error.response?.data?.message ||
        error.response?.statusText ||
        error.message ||
        "Error importing text";
      setMessage(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (!loading) {
      setGutenbergId("");
      setMessage("");
      setIsPublic(true);
      onClose();
    }
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={handleClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Import from Project Gutenberg</h2>
          <button className="modal-close" onClick={handleClose} disabled={loading}>
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="modal-body">
          {message && (
            <div className={`message ${message.includes("Successfully") ? "success" : "error"}`}>
              <FontAwesomeIcon
                icon={message.includes("Successfully") ? faCheckCircle : faExclamationTriangle}
                className="message-icon"
              />
              {message}
            </div>
          )}

          <form onSubmit={handleImport} className="import-form">
            <div className="form-group">
              <label htmlFor="gutenberg-id">
                <FontAwesomeIcon icon={faFileText} />
                Project Gutenberg ID:
              </label>
              <input
                id="gutenberg-id"
                type="text"
                value={gutenbergId}
                onChange={(e) => setGutenbergId(e.target.value)}
                placeholder="e.g., 11 for Alice's Adventures in Wonderland"
                className="gutenberg-input"
                disabled={loading}
              />
            </div>

            {user?.admin && (
              <div className="form-group privacy-group">
                <label className="privacy-label">
                  <input
                    type="checkbox"
                    checked={isPublic}
                    onChange={(e) => setIsPublic(e.target.checked)}
                    disabled={loading}
                  />
                  <FontAwesomeIcon icon={isPublic ? faGlobe : faLock} className="privacy-icon" />
                  Make this source text public
                </label>
                <small className="privacy-help">
                  {isPublic
                    ? "Other users will be able to see and use this text"
                    : "Only you will be able to see and use this text"}
                </small>
              </div>
            )}

            {!user?.admin && (
              <div className="form-group privacy-info">
                <p className="privacy-notice">
                  <FontAwesomeIcon icon={faLock} className="privacy-icon" />
                  Your imported texts will be private (visible only to you)
                </p>
              </div>
            )}

            <div className="modal-actions">
              <button
                type="button"
                className="btn btn-secondary"
                onClick={handleClose}
                disabled={loading}
              >
                Cancel
              </button>
              <button type="submit" className="btn btn-primary" disabled={loading || !gutenbergId}>
                {loading ? (
                  <>
                    <FontAwesomeIcon icon={faDownload} className="fa-spin" />
                    <span>Importing...</span>
                  </>
                ) : (
                  <>
                    <FontAwesomeIcon icon={faPlus} />
                    <span>Import Text</span>
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default SourceTextImportModal;
