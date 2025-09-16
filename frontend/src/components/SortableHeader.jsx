import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSort, faSortUp, faSortDown } from "../config/fontawesome";

function SortableHeader({ children, sortKey, currentSort, onSort, className = "" }) {
  const handleSort = (e) => {
    e.preventDefault();
    e.stopPropagation();
    const newDirection =
      currentSort.sortBy === sortKey && currentSort.sortDirection === "asc" ? "desc" : "asc";
    onSort(sortKey, newDirection);
  };

  const getSortIcon = () => {
    if (currentSort.sortBy !== sortKey) {
      return faSort;
    }
    return currentSort.sortDirection === "asc" ? faSortUp : faSortDown;
  };

  const isActive = currentSort.sortBy === sortKey;

  return (
    <th className={`sortable-header ${className} ${isActive ? "active" : ""}`} onClick={handleSort}>
      <div className="header-content">
        <span>{children}</span>
        <FontAwesomeIcon icon={getSortIcon()} className={`sort-icon ${isActive ? "active" : ""}`} />
      </div>
    </th>
  );
}

export default SortableHeader;
