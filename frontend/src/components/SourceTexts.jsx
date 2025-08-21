import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faInfoCircle,
  faFileText,
  faPlus,
  faCheckCircle,
  faExclamationTriangle,
} from "../config/fontawesome";
import { sourceTextsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";
import SourceTextImportModal from "./SourceTextImportModal";

function SourceTexts() {
  const [sourceTexts, setSourceTexts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const { user } = useAuth();

  useEffect(() => {
    loadSourceTexts();
  }, []);

  const loadSourceTexts = async () => {
    setLoading(true);
    try {
      const response = await sourceTextsAPI.getAll();
      setSourceTexts(response.data);
    } catch {
      setMessage("Error loading source texts");
    } finally {
      setLoading(false);
    }
  };

  const handleImportSuccess = (successMessage) => {
    setMessage(successMessage);
    loadSourceTexts();
  };

  return (
    <div className="source-texts">
      <div className="header">
        <h1>Public Source Texts</h1>
      </div>

      {message && (
        <div className={`message ${message.includes("Error") ? "error" : "success"}`}>
          <FontAwesomeIcon
            icon={message.includes("Error") ? faExclamationTriangle : faCheckCircle}
            className="message-icon"
          />
          {message}
        </div>
      )}

      <div className="texts-section">
        <h3>
          <FontAwesomeIcon icon={faFileText} className="section-icon" />
          Available Source Texts ({sourceTexts.length})
        </h3>

        {loading ? (
          <div className="loading">Loading source texts...</div>
        ) : sourceTexts.length === 0 ? (
          <div className="empty-state">
            <p>
              <FontAwesomeIcon icon={faInfoCircle} className="empty-icon" />
              No public source texts available yet.
            </p>
            {user?.admin && (
              <p>
                <FontAwesomeIcon icon={faPlus} className="admin-hint" />
                You can import texts from Project Gutenberg using the Import button above.
              </p>
            )}
          </div>
        ) : (
          <div className="texts-table-container">
            <table className="texts-table">
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Word Count</th>
                  <th>Gutenberg ID</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {sourceTexts.map((text) => (
                  <tr key={text.id}>
                    <td className="title-cell">
                      <Link to={`/source-texts/${text.id}`} className="title-link">
                        {text.title}
                      </Link>
                    </td>
                    <td className="word-count-cell">{(text.word_count || 0).toLocaleString()}</td>
                    <td className="gutenberg-id-cell">{text.gutenberg_id || "—"}</td>
                    <td className="actions-cell">
                      <Link to={`/source-texts/${text.id}`} className="btn btn-ghost btn-sm">
                        <FontAwesomeIcon icon={faEye} />
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <SourceTextImportModal
        isOpen={isImportModalOpen}
        onClose={() => setIsImportModalOpen(false)}
        onSuccess={handleImportSuccess}
      />
    </div>
  );
}

export default SourceTexts;
