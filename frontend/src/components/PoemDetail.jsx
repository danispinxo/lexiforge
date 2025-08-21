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
      } catch {
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
          Back to All Public Poems
        </Link>
        <div className="actions">
          <Link to={`/source-texts/${poem.source_text.id}`} className="btn btn-secondary">
            View Source Text
          </Link>
        </div>
      </div>

      <div className="poem-info">
        <h1>{poem.title}</h1>

        <div className="metadata">
          <span className="technique">Technique: {poem.technique_used}</span>
          <span className="author">Author: {poem.author_name || "Anonymous"}</span>
          <span className="date">Created: {new Date(poem.created_at).toLocaleDateString()}</span>
        </div>

        <div className="source-info">
          <p>
            Generated from:{" "}
            <Link to={`/source-texts/${poem.source_text.id}`} className="source-link">
              {poem.source_text.title}
            </Link>
          </p>
        </div>
      </div>

      <div className="poem-content">
        <h3>Poem</h3>
        <div
          className={`poem-text ${
            poem.technique_used === "erasure" || poem.technique_used === "blackout"
              ? "erasure-poem"
              : "lineated-poem"
          }`}
        >
          {poem.technique_used === "erasure" || poem.technique_used === "blackout" ? (
            <div className="erasure-pages-container">
              {(() => {
                try {
                  const parsedContent = JSON.parse(poem.content);
                  if (parsedContent.type === "erasure_pages") {
                    return parsedContent.pages.map((page) => (
                      <div key={page.number} className="erasure-page">
                        <div className="page-number">Page {page.number}</div>
                        {poem.technique_used === "blackout" || parsedContent.is_blackout ? (
                          <div
                            className="page-content blackout-content"
                            dangerouslySetInnerHTML={{ __html: page.content }}
                          />
                        ) : (
                          <pre className="page-content">{page.content}</pre>
                        )}
                      </div>
                    ));
                  }
                } catch {
                  return <pre className="erasure-text">{poem.content}</pre>;
                }
                return <pre className="erasure-text">{poem.content}</pre>;
              })()}
            </div>
          ) : (
            poem.content.split("\n").map((line, index) => (
              <div key={index} className="poem-line">
                {line || "\u00A0"}
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

export default PoemDetail;
