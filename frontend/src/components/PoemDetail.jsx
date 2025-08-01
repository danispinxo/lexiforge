import { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import { poemsAPI } from "../services/api";

function PoemDetail() {
  const { id } = useParams();
  const [poem, setPoem] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const loadPoem = async () => {
      try {
        const response = await poemsAPI.getById(id);
        setPoem(response.data);
      } catch (error) {
        console.error("Error loading poem:", error);
        setError("Poem not found");
      } finally {
        setLoading(false);
      }
    };

    loadPoem();
  }, [id]);

  if (loading) return <div className="loading">Loading poem...</div>;
  if (error) return <div className="error">{error}</div>;
  if (!poem) return <div className="error">Poem not found</div>;

  return (
    <div className="poem-detail">
      <div className="header">
        <Link to="/poems" className="back-link">
          ← Back to All Poems
        </Link>
        <div className="actions">
          <Link
            to={`/source-texts/${poem.source_text.id}`}
            className="btn btn-secondary"
          >
            View Source Text
          </Link>
        </div>
      </div>

      <div className="poem-info">
        <h1>{poem.title}</h1>

        <div className="metadata">
          <span className="technique">Technique: {poem.technique_used}</span>
          <span className="date">
            Created: {new Date(poem.created_at).toLocaleDateString()}
          </span>
        </div>

        <div className="source-info">
          <p>
            Generated from:{" "}
            <Link
              to={`/source-texts/${poem.source_text.id}`}
              className="source-link"
            >
              {poem.source_text.title}
            </Link>
          </p>
        </div>
      </div>

      <div className="poem-content">
        <h3>Poem</h3>
        <div className="poem-text">
          {poem.content.split("\n").map((line, index) => (
            <div key={index} className="poem-line">
              {line || "\u00A0"} {/* Non-breaking space for empty lines */}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default PoemDetail;
