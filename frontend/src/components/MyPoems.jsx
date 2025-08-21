import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faExclamationTriangle,
  faInfoCircle,
  faCalendar,
  faLock,
  faGlobe,
} from "../config/fontawesome";
import { poemsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";

function MyPoems() {
  const [poems, setPoems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const { user } = useAuth();

  useEffect(() => {
    if (user) {
      loadMyPoems();
    } else {
      setLoading(false);
    }
  }, [user]);

  const loadMyPoems = async () => {
    try {
      const response = await poemsAPI.getMine();
      setPoems(response.data);
    } catch {
      setError("Error loading your poems");
    } finally {
      setLoading(false);
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
            You haven't generated any poems yet.
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
                  <th>Privacy</th>
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
                      <Link to={`/poems/${poem.id}`} className="btn btn-outline btn-sm">
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

export default MyPoems;
