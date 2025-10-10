import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faUsers, faSpinner, faExclamationTriangle } from "../config/fontawesome";
import { useAuth } from "../hooks/useAuth";
import api from "../services/api";

function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!user) {
      navigate("/login");
      return;
    }

    const fetchUsers = async () => {
      try {
        setLoading(true);
        setError("");
        const response = await api.get("/users");

        if (response.data.success) {
          setUsers(response.data.users);
        } else {
          setError(response.data.message || "Failed to load users");
        }
      } catch (error) {
        if (error.response?.status === 401) {
          setError("Authentication required to view users list.");
        } else if (error.response?.status === 429) {
          setError("Too many requests. Please try again later.");
        } else {
          setError("Failed to load users. Please try again.");
        }
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, [user, navigate]);

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  if (loading) {
    return (
      <div className="loading-container">
        <FontAwesomeIcon icon={faSpinner} spin className="loading-spinner" />
        <p>Loading users...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="error-container">
        <FontAwesomeIcon icon={faExclamationTriangle} className="error-icon" />
        <h2>Unable to Load Users</h2>
        <p>{error}</p>
      </div>
    );
  }

  return (
    <div className="users-page">
      <div className="page-header">
        <div className="header-content">
          <FontAwesomeIcon icon={faUsers} className="page-icon" />
          <div>
            <h1>Community Members</h1>
          </div>
        </div>
      </div>

      <div className="users-stats">
        <div className="stat-card">
          <span className="stat-number">{users.length}</span>
          <span className="stat-label">Active Users</span>
        </div>
        <div className="stat-card">
          <span className="stat-number">
            {users.reduce((total, user) => total + user.source_texts_count, 0)}
          </span>
          <span className="stat-label">Source Texts</span>
        </div>
        <div className="stat-card">
          <span className="stat-number">
            {users.reduce((total, user) => total + user.poems_count, 0)}
          </span>
          <span className="stat-label">Poems Generated</span>
        </div>
      </div>

      <div className="users-table-container">
        <table className="users-table">
          <thead>
            <tr>
              <th>User</th>
              <th>Source Texts</th>
              <th>Poems</th>
              <th>Joined</th>
            </tr>
          </thead>
          <tbody>
            {users.map((userData) => (
              <tr key={userData.id}>
                <td className="user-cell">
                  <div className="user-info">
                    <div className="user-avatar-container">
                      {userData.gravatar_url ? (
                        <img
                          src={userData.gravatar_url}
                          alt={`${userData.username}'s avatar`}
                          className="user-avatar"
                          onError={(e) => {
                            e.target.style.display = "none";
                            e.target.nextElementSibling.style.display = "flex";
                          }}
                        />
                      ) : null}
                      <div
                        className="user-avatar-fallback"
                        style={{
                          display: userData.gravatar_url ? "none" : "flex",
                        }}
                      >
                        <FontAwesomeIcon icon={faUsers} />
                      </div>
                    </div>
                    <div className="user-details">
                      <div className="user-name">
                        {userData.full_name || userData.username}
                        {userData.user_type === "admin" && (
                          <span className="admin-badge">Admin</span>
                        )}
                      </div>
                      {userData.full_name && userData.full_name !== userData.username && (
                        <div className="user-username">@{userData.username}</div>
                      )}
                    </div>
                  </div>
                </td>
                <td className="stat-cell">
                  <span className="stat-count">{userData.source_texts_count}</span>
                </td>
                <td className="stat-cell">
                  <span className="stat-count">{userData.poems_count}</span>
                </td>
                <td className="date-cell">{formatDate(userData.created_at)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {users.length === 0 && (
        <div className="empty-state">
          <FontAwesomeIcon icon={faUsers} className="empty-icon" />
          <h2>No Users Found</h2>
          <p>There are currently no users to display.</p>
        </div>
      )}
    </div>
  );
}

export default Users;
