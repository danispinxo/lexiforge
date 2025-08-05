import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
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
    } catch (error) {
      console.error("Error loading poems:", error);
      setError("Error loading poems");
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="loading">Loading poems...</div>;

  return (
    <div className="poems">
      <div className="header">
        <h1>Generated Poems</h1>
        <Link to="/source-texts" className="btn btn-secondary">
          Back to Source Texts
        </Link>
      </div>

      {error && <div className="message error">{error}</div>}

      {poems.length === 0 ? (
        <div className="empty-state">
          <p>No poems generated yet.</p>
          <p>
            <Link to="/source-texts">Import some source texts</Link> and
            generate cut-up poems!
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
                      <span className="technique-badge">
                        {poem.technique_used}
                      </span>
                    </td>
                    <td className="source-cell">
                      {poem.source_text ? (
                        <Link
                          to={`/source-texts/${poem.source_text.id}`}
                          className="source-link"
                        >
                          {poem.source_text.title}
                        </Link>
                      ) : (
                        <span className="unknown-source">Unknown source</span>
                      )}
                    </td>
                    <td className="date-cell">
                      {new Date(poem.created_at).toLocaleDateString()}
                    </td>
                    <td className="actions-cell">
                      <Link
                        to={`/poems/${poem.id}`}
                        className="btn btn-ghost btn-sm"
                      >
                        View Poem
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
