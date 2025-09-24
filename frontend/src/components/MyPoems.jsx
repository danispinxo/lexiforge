import { useState, useEffect, useCallback } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faEdit,
  faTrash,
  faExclamationTriangle,
  faInfoCircle,
  faCalendar,
  faLock,
  faGlobe,
  faSearch,
} from "../config/fontawesome";
import { poemsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";
import Pagination from "./Pagination";
import SortableHeader from "./SortableHeader";

function MyPoems() {
  const [poems, setPoems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [deleting, setDeleting] = useState(null);
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
  const { user } = useAuth();

  const loadMyPoems = useCallback(
    async (page = 1) => {
      if (!user) return;
      setLoading(true);
      try {
        const response = await poemsAPI.getMine(page, 10, searchOptions);
        setPoems(response.data.poems);
        setPagination(response.data.pagination);
      } catch {
        setError("Error loading your poems");
      } finally {
        setLoading(false);
      }
    },
    [user, searchOptions]
  );

  useEffect(() => {
    if (user) {
      loadMyPoems(currentPage);
    } else {
      setLoading(false);
    }
  }, [user, currentPage, loadMyPoems]);

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

  const handleDeletePoem = async (poemId, poemTitle) => {
    if (!window.confirm(`Are you sure you want to delete "${poemTitle}"? This cannot be undone.`)) {
      return;
    }

    setDeleting(poemId);
    setError("");

    try {
      const response = await poemsAPI.delete(poemId);
      if (response.data.success) {
        loadMyPoems(currentPage);
      } else {
        setError(response.data.message || "Failed to delete poem");
      }
    } catch (err) {
      setError(err.response?.data?.message || "Failed to delete poem");
    } finally {
      setDeleting(null);
    }
  };

  if (!user) {
    return (
      <div className="poems">
        <div className="auth-required">
          <h1>My Poems</h1>
          <p>
            Please <Link to="/login">log in</Link> to view your generated poems.
          </p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="poems">
        <div className="loading">Loading your poems...</div>
      </div>
    );
  }

  return (
    <div className="poems">
      <div className="header">
        <h1>My Generated Poems</h1>
      </div>

      <div className="search-and-filter">
        <div className="search-controls">
          <div className="search-box">
            <FontAwesomeIcon icon={faSearch} className="search-icon" />
            <input
              type="text"
              placeholder="Search your poems by title or content..."
              value={searchOptions.search}
              onChange={handleSearch}
              className="search-input"
            />
          </div>
        </div>
      </div>

      {error && (
        <div className="message error">
          <FontAwesomeIcon icon={faExclamationTriangle} className="message-icon" />
          {error}
        </div>
      )}

      {poems.length === 0 && !loading ? (
        <div className="empty-state">
          <p>
            <FontAwesomeIcon icon={faInfoCircle} className="empty-icon" />
            {searchOptions.search
              ? "No poems found matching your search criteria."
              : "You haven't generated any poems yet."}
          </p>
        </div>
      ) : (
        <>
          <p className="poems-count">
            Found {pagination.total_count} generated poems
            {searchOptions.search && ` matching "${searchOptions.search}"`}
          </p>
          <div className="poems-table-container">
            <table className="poems-table">
              <thead>
                <tr>
                  <SortableHeader sortKey="title" currentSort={searchOptions} onSort={handleSort}>
                    Title
                  </SortableHeader>
                  <SortableHeader
                    sortKey="technique_used"
                    currentSort={searchOptions}
                    onSort={handleSort}
                  >
                    Technique
                  </SortableHeader>
                  <th>Source Text</th>
                  <th>Privacy</th>
                  <SortableHeader
                    sortKey="created_at"
                    currentSort={searchOptions}
                    onSort={handleSort}
                  >
                    Date Created
                  </SortableHeader>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {poems.map((poem) => (
                  <tr key={poem.id}>
                    <td className="title-cell">
                      <Link to={`/poems/${poem.id}`} className="title-link">
                        {poem.title}
                      </Link>
                    </td>
                    <td className="technique-cell">
                      <span className="technique-badge">{poem.technique_used}</span>
                    </td>
                    <td className="source-cell">
                      {poem.source_text ? (
                        <Link to={`/source-texts/${poem.source_text.id}`} className="source-link">
                          {poem.source_text.title}
                        </Link>
                      ) : (
                        <span className="unknown-source">Unknown source</span>
                      )}
                    </td>
                    <td className="privacy-cell">
                      <span className={`privacy-badge ${poem.is_public ? "public" : "private"}`}>
                        <FontAwesomeIcon icon={poem.is_public ? faGlobe : faLock} />
                        {poem.is_public ? "Public" : "Private"}
                      </span>
                    </td>
                    <td className="date-cell">
                      <FontAwesomeIcon icon={faCalendar} className="date-icon" />{" "}
                      {new Date(poem.created_at).toLocaleDateString()}
                    </td>
                    <td className="actions-cell">
                      <div className="action-buttons">
                        <Link
                          to={`/poems/${poem.id}`}
                          className="btn btn-secondary btn-sm"
                          title="View poem"
                        >
                          <FontAwesomeIcon icon={faEye} />
                        </Link>
                        <Link
                          to={`/poems/${poem.id}/edit`}
                          className="btn btn-secondary btn-sm"
                          title="Edit poem"
                        >
                          <FontAwesomeIcon icon={faEdit} />
                        </Link>
                        <button
                          onClick={() => handleDeletePoem(poem.id, poem.title)}
                          className="btn btn-secondary btn-sm"
                          title="Delete poem"
                          disabled={deleting === poem.id}
                        >
                          <FontAwesomeIcon icon={faTrash} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <Pagination
            currentPage={pagination.current_page}
            totalPages={pagination.total_pages}
            onPageChange={handlePageChange}
          />
        </>
      )}
    </div>
  );
}

export default MyPoems;
