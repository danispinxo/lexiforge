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

          <div className="poems-grid">
            {poems.map((poem) => (
              <div key={poem.id} className="poem-card">
                <h3>
                  <Link to={`/poems/${poem.id}`}>{poem.title}</Link>
                </h3>

                <div className="poem-meta">
                  <span className="technique">{poem.technique_used}</span>
                  <span className="date">
                    {new Date(poem.created_at).toLocaleDateString()}
                  </span>
                </div>

                <div className="source-info">
                  <span>From: </span>
                  <Link
                    to={`/source-texts/${poem.source_text.id}`}
                    className="source-link"
                  >
                    {poem.source_text.title}
                  </Link>
                  {poem.source_text.author && (
                    <span className="author">
                      {" "}
                      by {poem.source_text.author}
                    </span>
                  )}
                </div>

                <div className="content-preview">{poem.content_preview}</div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

export default Poems;
