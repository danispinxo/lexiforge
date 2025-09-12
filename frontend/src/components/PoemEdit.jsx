import { useState, useEffect } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTrash } from "../config/fontawesome";
import { poemsAPI } from "../services/api";
import { useAuth } from "../hooks/useAuth";
import PrivacyToggle from "./PrivacyToggle";

function PoemEdit() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [poem, setPoem] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [formData, setFormData] = useState({
    title: "",
    content: "",
    is_public: true,
  });
  const [editableContent, setEditableContent] = useState("");

  useEffect(() => {
    const loadPoem = async () => {
      try {
        const response = await poemsAPI.getById(id);
        const poemData = response.data;
        setPoem(poemData);

        const isErasure =
          poemData.technique_used === "erasure" || poemData.technique_used === "blackout";

        let editableText = "";
        if (isErasure) {
          try {
            const parsedContent = JSON.parse(poemData.content);
            if (parsedContent.type === "erasure_pages" && parsedContent.pages) {
              editableText = parsedContent.pages
                .map((page) => {
                  return page.content
                    .replace(/<[^>]*>/g, "")
                    .replace(/&nbsp;/g, " ")
                    .replace(/\s+/g, " ")
                    .trim();
                })
                .filter((text) => text.length > 0)
                .join("\n\n");
            }
          } catch {
            editableText = poemData.content;
          }
        } else {
          editableText = poemData.content;
        }

        setEditableContent(editableText);
        setFormData({
          title: poemData.title,
          content: poemData.content,
          is_public: poemData.is_public,
        });
      } catch {
        setError("Poem not found");
      } finally {
        setLoading(false);
      }
    };

    loadPoem();
  }, [id]);

  const canEdit = user && poem && poem.author_id === user.id && poem.author_type === user.type;

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    if (name === "content") {
      setEditableContent(value);
    } else {
      setFormData((prev) => ({
        ...prev,
        [name]: value,
      }));
    }
  };

  const handlePrivacyChange = (isPublic) => {
    setFormData((prev) => ({
      ...prev,
      is_public: isPublic,
    }));
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    setSuccess("");

    try {
      const dataToSave = {
        ...formData,
        content: editableContent,
      };

      const response = await poemsAPI.update(id, dataToSave);
      if (response.data.success) {
        setSuccess("Poem updated successfully!");
        setPoem(response.data.poem);
        setTimeout(() => {
          navigate(`/poems/${id}`);
        }, 1500);
      } else {
        setError(response.data.message || "Failed to update poem");
      }
    } catch (err) {
      setError(err.response?.data?.message || "Failed to update poem");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (
      !window.confirm("Are you sure you want to delete this poem? This action cannot be undone.")
    ) {
      return;
    }

    setDeleting(true);
    setError("");

    try {
      const response = await poemsAPI.delete(id);
      if (response.data.success) {
        setSuccess("Poem deleted successfully!");
        setTimeout(() => {
          navigate("/my-poems");
        }, 1500);
      } else {
        setError(response.data.message || "Failed to delete poem");
      }
    } catch (err) {
      setError(err.response?.data?.message || "Failed to delete poem");
    } finally {
      setDeleting(false);
    }
  };

  if (loading) return <div className="loading">Loading poem...</div>;
  if (error && !poem) return <div className="error">{error}</div>;
  if (!poem) return <div className="error">Poem not found</div>;
  if (!user) {
    return (
      <div className="poem-edit">
        <div className="auth-required">
          <h1>Edit Poem</h1>
          <p>
            Please <Link to="/login">log in</Link> to edit poems.
          </p>
        </div>
      </div>
    );
  }
  if (!canEdit) {
    return (
      <div className="poem-edit">
        <div className="unauthorized">
          <h1>Edit Poem</h1>
          <p>You can only edit your own poems.</p>
          <Link to={`/poems/${id}`} className="btn btn-primary">
            View Poem
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="poem-edit">
      <div className="header">
        <Link to={`/poems/${id}`} className="back-link">
          Back
        </Link>
        <h1>Edit Poem</h1>
        <div className="actions">
          <button
            type="button"
            className="btn btn-secondary"
            onClick={handleDelete}
            disabled={deleting}
          >
            <FontAwesomeIcon icon={faTrash} /> {deleting ? "Deleting..." : "Delete"}
          </button>
        </div>
      </div>

      {error && <div className="error">{error}</div>}
      {success && <div className="success">{success}</div>}

      <form onSubmit={handleSave} className="poem-edit-form">
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
            placeholder="Enter poem title"
          />
        </div>

        <div className="form-group">
          <label htmlFor="content">Content</label>
          <textarea
            id="content"
            name="content"
            value={editableContent}
            onChange={handleInputChange}
            required
            className="form-textarea poem-content-editor"
            placeholder="Enter your poem content"
            rows={15}
          />
        </div>

        <div className="form-group">
          <label>Privacy Settings</label>
          <PrivacyToggle
            isPublic={formData.is_public}
            onChange={handlePrivacyChange}
            contentType="poem"
          />
        </div>

        <div className="poem-metadata">
          <div className="metadata-item">
            <strong>Technique:</strong> {poem.technique_used}
          </div>
          <div className="metadata-item">
            <strong>Source Text:</strong>{" "}
            <Link to={`/source-texts/${poem.source_text.id}`} className="source-link">
              {poem.source_text.title}
            </Link>
          </div>
          <div className="metadata-item">
            <strong>Created:</strong> {new Date(poem.created_at).toLocaleDateString()}
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

export default PoemEdit;
