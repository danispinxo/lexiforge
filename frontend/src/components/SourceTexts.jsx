import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { sourceTextsAPI } from "../services/api";

function SourceTexts() {
  const [sourceTexts, setSourceTexts] = useState([]);
  const [gutenbergId, setGutenbergId] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  useEffect(() => {
    loadSourceTexts();
  }, []);

  const loadSourceTexts = async () => {
    try {
      const response = await sourceTextsAPI.getAll();
      setSourceTexts(response.data);
    } catch (error) {
      console.error("Error loading source texts:", error);
      setMessage("Error loading source texts");
    }
  };

  const handleImport = async (e) => {
    e.preventDefault();
    if (!gutenbergId) return;

    setLoading(true);
    setMessage("");

    try {
      const response = await sourceTextsAPI.importFromGutenberg(gutenbergId);
      if (response.data.success) {
        setMessage(
          `Successfully imported "${response.data.source_text.title}"`
        );
        setGutenbergId("");
        loadSourceTexts(); // Refresh the list
      }
    } catch (error) {
      setMessage(error.response?.data?.message || "Error importing text");
    } finally {
      setLoading(false);
    }
  };

  const popularBooks = [
    { id: 1342, title: "Pride and Prejudice", author: "Jane Austen" },
    {
      id: 11,
      title: "Alice's Adventures in Wonderland",
      author: "Lewis Carroll",
    },
    { id: 74, title: "The Adventures of Tom Sawyer", author: "Mark Twain" },
    {
      id: 1661,
      title: "The Adventures of Sherlock Holmes",
      author: "Arthur Conan Doyle",
    },
    { id: 2701, title: "Moby Dick", author: "Herman Melville" },
    {
      id: 844,
      title: "The Importance of Being Earnest",
      author: "Oscar Wilde",
    },
  ];

  return (
    <div className="source-texts">
      <div className="header">
        <h1>Source Texts</h1>
        <Link to="/poems" className="btn btn-secondary">
          View Generated Poems
        </Link>
      </div>

      {/* Import Section */}
      <div className="import-section">
        <h3>Import from Project Gutenberg</h3>

        <form onSubmit={handleImport}>
          <div className="form-group">
            <label htmlFor="gutenberg-id">Enter Gutenberg ID:</label>
            <input
              id="gutenberg-id"
              type="number"
              value={gutenbergId}
              onChange={(e) => setGutenbergId(e.target.value)}
              placeholder="e.g., 1342 for Pride and Prejudice"
              disabled={loading}
            />
            <button type="submit" disabled={loading || !gutenbergId}>
              {loading ? "Importing..." : "Import Text"}
            </button>
          </div>
        </form>

        {message && (
          <div
            className={`message ${
              message.includes("Error") ? "error" : "success"
            }`}
          >
            {message}
          </div>
        )}

        <details className="popular-books">
          <summary>
            <strong>Popular Books to Try:</strong>
          </summary>
          <div className="books-list">
            {popularBooks.map((book) => (
              <div key={book.id} className="book-item">
                <strong>{book.id}</strong>: {book.title} by {book.author}
              </div>
            ))}
          </div>
        </details>

        <p className="help-text">
          <strong>How to find Gutenberg IDs:</strong> Visit{" "}
          <a
            href="https://www.gutenberg.org/"
            target="_blank"
            rel="noopener noreferrer"
          >
            gutenberg.org
          </a>
          , search for a book, and look for the number in the URL (e.g.,
          /ebooks/1342)
        </p>
      </div>

      {/* Source Texts List */}
      <div className="texts-section">
        <h3>Your Source Texts ({sourceTexts.length})</h3>

        {sourceTexts.length === 0 ? (
          <p>
            No source texts imported yet. Import one from Project Gutenberg
            above!
          </p>
        ) : (
          <div className="texts-grid">
            {sourceTexts.map((text) => (
              <div key={text.id} className="text-card">
                <h4>
                  <Link to={`/source-texts/${text.id}`}>{text.title}</Link>
                </h4>

                <div className="text-info">
                  <span className="word-count">
                    {(text.word_count || 0).toLocaleString()} words
                  </span>
                  {text.gutenberg_id && (
                    <span className="gutenberg-id">
                      ID: {text.gutenberg_id}
                    </span>
                  )}
                </div>
                <p className="preview">{text.content_preview}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default SourceTexts;
