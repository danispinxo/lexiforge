import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faFileText,
  faLock,
  faGlobe,
  faExclamationTriangle,
  faCheckCircle,
  faPlus,
} from "../config/fontawesome";
import { sourceTextsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";
import SourceTextImportModal from "./SourceTextImportModal";
import CustomSourceTextModal from "./CustomSourceTextModal";

function MySourceTexts() {
  const [sourceTexts, setSourceTexts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false);
  const { user } = useAuth();

  useEffect(() => {
    loadMySourceTexts();
  }, []);

  const loadMySourceTexts = async () => {
    setLoading(true);
    try {
      const response = await sourceTextsAPI.getMine();
      setSourceTexts(response.data);
    } catch {
      setMessage("Error loading your source texts");
    } finally {
      setLoading(false);
    }
  };

  const handleImportSuccess = (successMessage) => {
    setMessage(successMessage);
    loadMySourceTexts();
  };

  const handleUploadSuccess = (successMessage) => {
    setMessage(successMessage);
    loadMySourceTexts();
  };

  if (!user) {
    return (
      <div className="source-texts">
        <div className="auth-required">
          <h1>My Source Texts</h1>
          <p>
            Please <Link to="/login">log in</Link> to manage your source texts.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="source-texts">
      <div className="header">
        <h1>My Source Texts</h1>
        <div className="header-actions">
          <div className="action-buttons">
            <button className="btn btn-secondary" onClick={() => setIsImportModalOpen(true)}>
              <FontAwesomeIcon icon={faPlus} /> Import from Gutenberg
            </button>
            <button className="btn btn-primary" onClick={() => setIsUploadModalOpen(true)}>
              <FontAwesomeIcon icon={faPlus} /> Add Custom Text
            </button>
          </div>
        </div>
      </div>

      {message && (
        <div className={`message ${message.includes("Successfully") ? "success" : "error"}`}>
          <FontAwesomeIcon
            icon={message.includes("Successfully") ? faCheckCircle : faExclamationTriangle}
            className="message-icon"
          />
          {message}
        </div>
      )}

      {loading ? (
        <div className="loading">Loading your source texts...</div>
      ) : sourceTexts.length === 0 ? (
        <div className="empty-state">
          <p>You haven't imported any source texts yet.</p>
          <p>
            Use the buttons above to import texts from Project Gutenberg or add your own custom
            texts.
          </p>
        </div>
      ) : (
        <div className="texts-section">
          <h3>
            <FontAwesomeIcon icon={faFileText} className="section-icon" />
            Your Source Texts ({sourceTexts.length})
          </h3>
          <div className="texts-table-container">
            <table className="texts-table">
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Privacy</th>
                  <th>Gutenberg ID</th>
                  <th>Poems Generated</th>
                  <th>Date Added</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {sourceTexts.map((sourceText) => (
                  <tr key={sourceText.id}>
                    <td className="title-cell">
                      <Link to={`/source-texts/${sourceText.id}`} className="title-link">
                        <FontAwesomeIcon icon={faFileText} className="file-icon" />
                        {sourceText.title}
                      </Link>
                    </td>
                    <td className="privacy-cell">
                      <span
                        className={`privacy-badge ${sourceText.is_public ? "public" : "private"}`}
                      >
                        <FontAwesomeIcon icon={sourceText.is_public ? faGlobe : faLock} />
                        {sourceText.is_public ? "Public" : "Private"}
                      </span>
                    </td>
                    <td className="gutenberg-cell">
                      {sourceText.gutenberg_id ? (
                        <a
                          href={`https://www.gutenberg.org/ebooks/${sourceText.gutenberg_id}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="gutenberg-link"
                        >
                          #{sourceText.gutenberg_id}
                        </a>
                      ) : (
                        <span className="custom-text">Custom</span>
                      )}
                    </td>
                    <td className="poems-cell">
                      <span className="poems-count">{sourceText.poems_count || 0}</span>
                    </td>
                    <td className="date-cell">
                      {new Date(sourceText.created_at).toLocaleDateString()}
                    </td>
                    <td className="actions-cell">
                      <Link
                        to={`/source-texts/${sourceText.id}`}
                        className="btn btn-outline btn-sm"
                      >
                        <FontAwesomeIcon icon={faEye} />
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      <SourceTextImportModal
        isOpen={isImportModalOpen}
        onClose={() => setIsImportModalOpen(false)}
        onSuccess={handleImportSuccess}
      />

      <CustomSourceTextModal
        isOpen={isUploadModalOpen}
        onClose={() => setIsUploadModalOpen(false)}
        onSuccess={handleUploadSuccess}
      />
    </div>
  );
}

export default MySourceTexts;
