import { useState, useEffect, useCallback } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faExclamationTriangle,
  faInfoCircle,
  faCalendar,
  faSearch,
} from "../config/fontawesome";
import { poemsAPI } from "../services/api";
import Pagination from "./Pagination";
import SortableHeader from "./SortableHeader";

function Poems() {
  const [poems, setPoems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
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

  const loadPoems = useCallback(
    async (page = 1) => {
      setLoading(true);
      try {
        const response = await poemsAPI.getAll(page, 10, searchOptions);
        setPoems(response.data.poems);
        setPagination(response.data.pagination);
      } catch {
        setError("Error loading poems");
      } finally {
        setLoading(false);
      }
    },
    [searchOptions]
  );

  useEffect(() => {
    loadPoems(currentPage);
  }, [currentPage, loadPoems]);

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
    <div className="poems">
      <div className="header">
        <h1>Public Generated Poems</h1>
      </div>

      <div className="search-and-filter">
        <div className="search-controls">
          <div className="search-box">
            <FontAwesomeIcon icon={faSearch} className="search-icon" />
            <input
              type="text"
              placeholder="Search poems by title or content..."
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

      {loading ? (
        <div className="loading">Loading poems...</div>
      ) : poems.length === 0 ? (
        <div className="empty-state">
          <p>
            <FontAwesomeIcon icon={faInfoCircle} className="empty-icon" />
            No poems found.
          </p>
          <p>
            <Link to="/source-texts">Import some source texts</Link> and generate poems!
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
                  <SortableHeader sortKey="author" currentSort={searchOptions} onSort={handleSort}>
                    Author
                  </SortableHeader>
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
                    <td className="author-cell">
                      <span className="author-name">{poem.author_name || "Anonymous"}</span>
                    </td>
                    <td className="date-cell">
                      <FontAwesomeIcon icon={faCalendar} className="date-icon" />{" "}
                      {new Date(poem.created_at).toLocaleDateString()}
                    </td>
                    <td className="actions-cell">
                      <Link to={`/poems/${poem.id}`} className="btn btn-ghost btn-sm">
                        <FontAwesomeIcon icon={faEye} />
                      </Link>
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

export default Poems;
