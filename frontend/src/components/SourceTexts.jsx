import { useState, useEffect, useCallback } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faInfoCircle,
  faFileText,
  faCheckCircle,
  faExclamationTriangle,
  faSearch,
} from "../config/fontawesome";
import { sourceTextsAPI } from "../services/api";
import SourceTextImportModal from "./SourceTextImportModal";
import Pagination from "./Pagination";
import SortableHeader from "./SortableHeader";

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
  const [searchOptions, setSearchOptions] = useState({
    search: "",
    sortBy: "created_at",
    sortDirection: "desc",
  });

  const loadSourceTexts = useCallback(
    async (page = 1) => {
      setLoading(true);
      try {
        const response = await sourceTextsAPI.getAll(page, 10, searchOptions);
        setSourceTexts(response.data.source_texts);
        setPagination(response.data.pagination);
      } catch {
        setMessage("Error loading source texts");
      } finally {
        setLoading(false);
      }
    },
    [searchOptions]
  );

  useEffect(() => {
    loadSourceTexts(currentPage);
  }, [currentPage, loadSourceTexts]);

  const handleImportSuccess = (successMessage) => {
    setMessage(successMessage);
    loadSourceTexts(currentPage);
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleSearch = (e) => {
    const search = e.target.value;
    setSearchOptions((prev) => ({ ...prev, search }));
    setCurrentPage(1);
  };

  const handleSort = (sortBy, sortDirection) => {
    setSearchOptions((prev) => ({ ...prev, sortBy, sortDirection }));
    setCurrentPage(1);
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

      <div className="search-and-filter">
        <div className="search-controls">
          <div className="search-box">
            <FontAwesomeIcon icon={faSearch} className="search-icon" />
            <input
              type="text"
              placeholder="Search source texts by title or content..."
              value={searchOptions.search}
              onChange={handleSearch}
              className="search-input"
            />
          </div>
        </div>
      </div>

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
                  <SortableHeader sortKey="title" currentSort={searchOptions} onSort={handleSort}>
                    Title
                  </SortableHeader>
                  <SortableHeader
                    sortKey="word_count"
                    currentSort={searchOptions}
                    onSort={handleSort}
                  >
                    Word Count
                  </SortableHeader>
                  <SortableHeader
                    sortKey="gutenberg_id"
                    currentSort={searchOptions}
                    onSort={handleSort}
                  >
                    Gutenberg ID
                  </SortableHeader>
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
