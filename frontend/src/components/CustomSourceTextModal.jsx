import { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faUpload,
  faPlus,
  faCheckCircle,
  faExclamationTriangle,
  faTimes,
  faPaste,
} from "../config/fontawesome";
import { sourceTextsAPI } from "../services/api";

function CustomSourceTextModal({ isOpen, onClose, onSuccess }) {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!title.trim() || !content.trim()) {
      setMessage("Please provide both title and content");
      return;
    }

    setLoading(true);
    setMessage("");

    try {
      const response = await sourceTextsAPI.createCustom(title.trim(), content.trim());
      if (response.data.success) {
        setMessage(`Successfully added "${response.data.source_text.title}"`);
        setTitle("");
        setContent("");
        setTimeout(() => {
          onSuccess(response.data.message);
          onClose();
          setMessage("");
        }, 1500);
      } else {
        setMessage(response.data.message || "Failed to add text");
      }
    } catch (error) {
      const errorMessage =
        error.response?.data?.message ||
        error.response?.statusText ||
        error.message ||
        "Error adding text";
      setMessage(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (!loading) {
      setTitle("");
      setContent("");
      setMessage("");
      onClose();
    }
  };

  const handlePasteFromClipboard = async () => {
    try {
      const text = await navigator.clipboard.readText();
      setContent(text);
      setMessage("Content pasted from clipboard");
      setTimeout(() => setMessage(""), 2000);
    } catch {
      setMessage("Could not access clipboard. Please paste manually.");
    }
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={handleClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Add Custom Source Text</h2>
          <button className="modal-close" onClick={handleClose} disabled={loading}>
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="modal-body">
          {message && (
            <div className="message">
              <FontAwesomeIcon
                icon={message.includes("Successfully") ? faCheckCircle : faExclamationTriangle}
                className="message-icon"
              />
              {message}
            </div>
          )}

          <form onSubmit={handleUpload} className="upload-form">
            <div className="form-group">
              <label htmlFor="title">Title:</label>
              <input
                id="title"
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Enter a title for your source text"
                className="title-input"
                disabled={loading}
                required
              />
            </div>
            <div className="form-group">
              <label htmlFor="content">Content:</label>
              <div className="paste-area">
                <textarea
                  id="content"
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  placeholder="Paste your text content here..."
                  className="content-textarea"
                  rows={10}
                  disabled={loading}
                  required
                />
              </div>
            </div>
            <button
              type="button"
              className="paste-btn"
              onClick={handlePasteFromClipboard}
              disabled={loading}
            >
              <FontAwesomeIcon icon={faPaste} />
              Paste from Clipboard
            </button>

            <div className="modal-actions">
              <button
                type="button"
                className="btn btn-secondary"
                onClick={handleClose}
                disabled={loading}
              >
                Cancel
              </button>
              <button
                type="submit"
                className="btn btn-primary"
                disabled={loading || !title.trim() || !content.trim()}
              >
                {loading ? (
                  <>
                    <FontAwesomeIcon icon={faUpload} className="fa-spin" />
                    <span>Adding...</span>
                  </>
                ) : (
                  <>
                    <FontAwesomeIcon icon={faPlus} />
                    <span>Add Text</span>
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

export default CustomSourceTextModal;
