import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faExclamationTriangle,
  faInfoCircle,
  faCalendar,
  faMagic,
} from "../config/fontawesome";
import { poemsAPI } from "../services/api";

function Poems() {
  const [poems, setPoems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    loadPoems();
  }, []);

  const loadPoems = async () => {
    try {
      const response = await poemsAPI.getAll();
      setPoems(response.data);
    } catch {
      setError("Error loading poems");
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="loading">Loading poems...</div>;

  return (
    <div className="poems">
      <div className="header">
        <h1>Public Generated Poems</h1>
      </div>

      {error && (
        <div className="message error">
          <FontAwesomeIcon icon={faExclamationTriangle} className="message-icon" />
          {error}
        </div>
      )}

      {poems.length === 0 ? (
        <div className="empty-state">
          <p>
            <FontAwesomeIcon icon={faInfoCircle} className="empty-icon" />
            No poems generated yet.
          </p>
          <p>
            <FontAwesomeIcon icon={faMagic} className="magic-icon" />
            <Link to="/source-texts">Import some source texts</Link> and generate cut-up poems!
          </p>
        </div>
      ) : (
        <>
          <p className="poems-count">Found {poems.length} generated poems</p>

          <div className="poems-table-container">
            <table className="poems-table">
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Technique</th>
                  <th>Source Text</th>
                  <th>Author</th>
                  <th>Date Created</th>
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
        </>
      )}
    </div>
  );
}

export default Poems;
