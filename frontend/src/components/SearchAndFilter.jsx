import { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSearch, faFilter, faTimes, faChevronDown } from "../config/fontawesome";

function SearchAndFilter({ onSearch, onFilter, showTextTypeFilter = true }) {
  const [searchTerm, setSearchTerm] = useState("");
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState({
    textType: "",
    minWordCount: "",
    maxWordCount: "",
  });

  const handleSearchChange = (e) => {
    const value = e.target.value;
    setSearchTerm(value);

    const timeoutId = setTimeout(() => {
      onSearch(value);
    }, 300);

    return () => clearTimeout(timeoutId);
  };

  const handleFilterChange = (filterKey, value) => {
    const newFilters = { ...filters, [filterKey]: value };
    setFilters(newFilters);
    onFilter(newFilters);
  };

  const clearFilters = () => {
    const clearedFilters = {
      textType: "",
      minWordCount: "",
      maxWordCount: "",
    };
    setFilters(clearedFilters);
    onFilter(clearedFilters);
  };

  const hasActiveFilters = Object.values(filters).some((value) => value !== "");

  return (
    <div className="search-and-filter">
      <div className="search-controls">
        <div className="search-box">
          <FontAwesomeIcon icon={faSearch} className="search-icon" />
          <input
            type="text"
            placeholder="Search by title or content..."
            value={searchTerm}
            onChange={handleSearchChange}
            className="search-input"
          />
          {searchTerm && (
            <button
              onClick={() => {
                setSearchTerm("");
                onSearch("");
              }}
              className="clear-search"
              aria-label="Clear search"
            >
              <FontAwesomeIcon icon={faTimes} />
            </button>
          )}
        </div>

        <button
          onClick={() => setShowFilters(!showFilters)}
          className={`filter-toggle ${hasActiveFilters ? "active" : ""}`}
          aria-label="Toggle filters"
        >
          <FontAwesomeIcon icon={faFilter} />
          Filters
          <FontAwesomeIcon
            icon={faChevronDown}
            className={`chevron ${showFilters ? "rotated" : ""}`}
          />
        </button>
      </div>

      {showFilters && (
        <div className="filter-panel">
          <div className="filter-row">
            {showTextTypeFilter && (
              <div className="filter-group">
                <label htmlFor="textType">Text Type:</label>
                <select
                  id="textType"
                  value={filters.textType}
                  onChange={(e) => handleFilterChange("textType", e.target.value)}
                  className="filter-select"
                >
                  <option value="">All Types</option>
                  <option value="gutenberg">Gutenberg Texts</option>
                  <option value="custom">Custom Texts</option>
                </select>
              </div>
            )}

            <div className="filter-group">
              <label htmlFor="minWordCount">Min Word Count:</label>
              <input
                id="minWordCount"
                type="number"
                placeholder="0"
                value={filters.minWordCount}
                onChange={(e) => handleFilterChange("minWordCount", e.target.value)}
                className="filter-input"
                min="0"
              />
            </div>

            <div className="filter-group">
              <label htmlFor="maxWordCount">Max Word Count:</label>
              <input
                id="maxWordCount"
                type="number"
                placeholder="No limit"
                value={filters.maxWordCount}
                onChange={(e) => handleFilterChange("maxWordCount", e.target.value)}
                className="filter-input"
                min="0"
              />
            </div>

            {hasActiveFilters && (
              <button
                onClick={clearFilters}
                className="clear-filters"
                aria-label="Clear all filters"
              >
                <FontAwesomeIcon icon={faTimes} />
                Clear
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export default SearchAndFilter;
