import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { POPULAR_BOOKS } from "../constants";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faInfoCircle,
  faFileText,
  faDownload,
  faPlus,
  faCheckCircle,
  faExclamationTriangle,
} from "../config/fontawesome";
import { sourceTextsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";

function SourceTexts() {
  const [sourceTexts, setSourceTexts] = useState([]);
  const [gutenbergId, setGutenbergId] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const { user } = useAuth();

  useEffect(() => {
    loadSourceTexts();
  }, []);

  const loadSourceTexts = async () => {
    try {
      const response = await sourceTextsAPI.getAll();
      setSourceTexts(response.data);
    } catch {
      setMessage("Error loading source texts");
    }
  };

  const handleImport = async (e) => {
    e.preventDefault();
    if (!gutenbergId) return;

    setLoading(true);
    setMessage("");

    try {
      const response = await sourceTextsAPI.importFromGutenberg(gutenbergId);
      if (response.data.success) {
        setMessage(`Successfully imported "${response.data.source_text.title}"`);
        setGutenbergId("");
        loadSourceTexts();
      }
    } catch (error) {
      setMessage(error.response?.data?.message || "Error importing text");
    } finally {
      setLoading(false);
    }
  };

  const popularBooks = POPULAR_BOOKS;

  return (
    <div className="source-texts">
      <div className="header">
        <h1>Source Texts</h1>
        <Link to="/poems" className="btn btn-secondary">
          View Generated Poems
        </Link>
      </div>

      {user?.admin && (
        <div className="import-section">
          <h3>Import from Project Gutenberg</h3>

          <form onSubmit={handleImport}>
            <div className="form-group">
              <label htmlFor="gutenberg-id">
                <FontAwesomeIcon icon={faFileText} />
                Enter Gutenberg ID:
              </label>
              <input
                id="gutenberg-id"
                type="number"
                value={gutenbergId}
                onChange={(e) => setGutenbergId(e.target.value)}
                placeholder="e.g., 1342 for Pride and Prejudice"
                disabled={loading}
              />
              <button type="submit" disabled={loading || !gutenbergId}>
                {loading ? (
                  <>
                    <FontAwesomeIcon icon={faDownload} className="fa-spin" />
                    {""}
                    <span>Importing...</span>
                  </>
                ) : (
                  <>
                    <FontAwesomeIcon icon={faPlus} /> <span>Import Text</span>
                  </>
                )}
              </button>
            </div>
          </form>

          {message && (
            <div className={`message ${message.includes("Error") ? "error" : "success"}`}>
              <FontAwesomeIcon
                icon={message.includes("Error") ? faExclamationTriangle : faCheckCircle}
                className="message-icon"
              />
              {message}
            </div>
          )}

          <details className="popular-books">
            <summary>
              <FontAwesomeIcon icon={faInfoCircle} className="summary-icon" />
              <strong>Popular Books to Try:</strong>
            </summary>
            <div className="books-list">
              {popularBooks.map((book) => (
                <div key={book.id} className="book-item">
                  <strong>{book.id}</strong>: {book.title} by {book.author}
                </div>
              ))}
            </div>
          </details>

          <p className="help-text">
            <FontAwesomeIcon icon={faInfoCircle} className="help-icon" />
            <strong>How to find Gutenberg IDs:</strong> Visit{" "}
            <a href="https://www.gutenberg.org/" target="_blank" rel="noopener noreferrer">
              gutenberg.org
            </a>
            , search for a book, and look for the number in the URL (e.g., /ebooks/1342)
          </p>
        </div>
      )}

      <div className="texts-section">
        <h3>
          <FontAwesomeIcon icon={faFileText} className="section-icon" />
          Available Source Texts ({sourceTexts.length})
        </h3>

        {sourceTexts.length === 0 ? (
          <p>
            <FontAwesomeIcon icon={faInfoCircle} className="empty-icon" />
            {user?.admin
              ? "No source texts imported yet. Import one from Project Gutenberg above!"
              : "No source texts available yet."}
          </p>
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
    </div>
  );
}

export default SourceTexts;
