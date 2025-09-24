import { useState, useEffect } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { sourceTextsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";

function SourceTextEdit() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [sourceText, setSourceText] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [formData, setFormData] = useState({
    title: "",
    content: "",
  });

  useEffect(() => {
    const loadSourceText = async () => {
      try {
        const response = await sourceTextsAPI.getById(id);
        const sourceTextData = response.data;
        setSourceText(sourceTextData);

        setFormData({
          title: sourceTextData.title,
          content: sourceTextData.content,
        });
      } catch {
        setError("Source text not found");
      } finally {
        setLoading(false);
      }
    };

    loadSourceText();
  }, [id]);

  const canEdit = user && user.admin;

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    setSuccess("");

    try {
      const response = await sourceTextsAPI.update(id, formData);
      if (response.data.success) {
        setSuccess("Source text updated successfully!");
        setSourceText(response.data.source_text);
        setTimeout(() => {
          navigate(`/source-texts/${id}`);
        }, 1500);
      } else {
        setError(response.data.message || "Failed to update source text");
      }
    } catch (err) {
      setError(err.response?.data?.message || "Failed to update source text");
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div className="loading">Loading source text...</div>;
  if (error && !sourceText) return <div className="error">{error}</div>;
  if (!sourceText) return <div className="error">Source text not found</div>;
  if (!user) {
    return (
      <div className="source-text-edit">
        <div className="auth-required">
          <h1>Edit Source Text</h1>
          <p>
            Please <Link to="/login">log in</Link> to edit source texts.
          </p>
        </div>
      </div>
    );
  }
  if (!canEdit) {
    return (
      <div className="source-text-edit">
        <div className="unauthorized">
          <h1>Edit Source Text</h1>
          <p>Only administrators can edit source texts.</p>
          <Link to={`/source-texts/${id}`} className="btn btn-primary">
            View Source Text
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="source-text-edit">
      <div className="header">
        <Link to={`/source-texts/${id}`} className="back-link">
          Back
        </Link>
        <h1>Edit Source Text</h1>
      </div>

      {error && <div className="error">{error}</div>}
      {success && <div className="success">{success}</div>}

      <form onSubmit={handleSave} className="source-text-edit-form">
        <div className="form-group">
          <label htmlFor="title">Title</label>
          <input
            type="text"
            id="title"
            name="title"
            value={formData.title}
            onChange={handleInputChange}
            required
            className="form-input"
            placeholder="Enter source text title"
          />
        </div>

        <div className="form-group">
          <label htmlFor="content">Content</label>
          <textarea
            id="content"
            name="content"
            value={formData.content}
            onChange={handleInputChange}
            required
            className="form-textarea source-text-content-editor"
            placeholder="Enter your source text content"
            rows={20}
          />
          <div className="content-stats">
            <span className="word-count">
              {formData.content.split(/\s+/).filter((word) => word.length > 0).length} words
            </span>
            <span className="char-count">{formData.content.length} characters</span>
          </div>
        </div>

        <div className="source-text-metadata">
          {sourceText.gutenberg_id && (
            <div className="metadata-item">
              <strong>Project Gutenberg ID:</strong> {sourceText.gutenberg_id}
            </div>
          )}
          <div className="metadata-item">
            <strong>Privacy:</strong> {sourceText.is_public ? "Public" : "Private"}
          </div>
          <div className="metadata-item">
            <strong>Created:</strong> {new Date(sourceText.created_at).toLocaleDateString()}
          </div>
          <div className="metadata-item">
            <strong>Owner:</strong> {sourceText.owner_name || "System"}
          </div>
          <div className="metadata-item">
            <strong>Poems Generated:</strong> {sourceText.poems_count || 0}
          </div>
        </div>

        <div className="form-actions">
          <button type="submit" className="btn btn-primary" disabled={saving}>
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </form>
    </div>
  );
}

export default SourceTextEdit;
