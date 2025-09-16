import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faInfoCircle,
  faFileText,
  faCheckCircle,
  faExclamationTriangle,
} from "../config/fontawesome";
import { sourceTextsAPI } from "../services/api";
import SourceTextImportModal from "./SourceTextImportModal";
import Pagination from "./Pagination";

function SourceTexts() {
  const [sourceTexts, setSourceTexts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pagination, setPagination] = useState({
    current_page: 1,
    total_pages: 1,
    total_count: 0,
    per_page: 10,
  });

  useEffect(() => {
    loadSourceTexts(currentPage);
  }, [currentPage]);

  const loadSourceTexts = async (page = 1) => {
    setLoading(true);
    try {
      const response = await sourceTextsAPI.getAll(page);
      setSourceTexts(response.data.source_texts);
      setPagination(response.data.pagination);
    } catch {
      setMessage("Error loading source texts");
    } finally {
      setLoading(false);
    }
  };

  const handleImportSuccess = (successMessage) => {
    setMessage(successMessage);
    loadSourceTexts(currentPage);
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: "smooth" });
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
          Available Source Texts ({pagination.total_count})
        </h3>

        {loading ? (
          <div className="loading">Loading source texts...</div>
        ) : sourceTexts.length === 0 ? (
          <div className="empty-state">
            <p>
              <FontAwesomeIcon icon={faInfoCircle} className="empty-icon" />
              No public source texts available yet.
            </p>
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

        <Pagination
          currentPage={pagination.current_page}
          totalPages={pagination.total_pages}
          onPageChange={handlePageChange}
          loading={loading}
        />
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
