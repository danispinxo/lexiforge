import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faUser,
  faSignOutAlt,
  faSignInAlt,
  faUserPlus,
  faShieldAlt,
  faChevronDown,
  faUserEdit,
} from "../config/fontawesome";
import { useAuth } from "../hooks/useAuth";

function AuthWrapper() {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const dropdownRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsDropdownOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = async () => {
    await logout();
    setIsDropdownOpen(false);
  };

  const handleLoginClick = () => {
    navigate("/login");
    setIsDropdownOpen(false);
  };

  const handleRegisterClick = () => {
    navigate("/register");
    setIsDropdownOpen(false);
  };

  const handleProfileClick = () => {
    navigate("/profile");
    setIsDropdownOpen(false);
  };

  return (
    <div className="auth-dropdown" ref={dropdownRef}>
      <button
        className="auth-dropdown-toggle"
        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
      >
        {user ? (
          <>
            {user.gravatar_url && (
              <img
                src={user.gravatar_url}
                alt={user.full_name || user.username || "User avatar"}
                className="user-avatar-small"
              />
            )}
            <span className="user-display-name">
              {user.full_name || user.username || user.email}
              {user.admin && (
                <FontAwesomeIcon
                  icon={faShieldAlt}
                  className="admin-indicator"
                />
              )}
            </span>
            <FontAwesomeIcon icon={faChevronDown} className="dropdown-arrow" />
          </>
        ) : (
          <>
            <FontAwesomeIcon icon={faUser} className="user-icon" />
            <span>Account</span>
            <FontAwesomeIcon icon={faChevronDown} className="dropdown-arrow" />
          </>
        )}
      </button>

      {isDropdownOpen && (
        <div className="auth-dropdown-menu">
          {user ? (
            <>
              <div className="dropdown-header">
                <span>
                  Welcome, {user.full_name || user.username || user.email}
                  {user.admin && (
                    <FontAwesomeIcon
                      icon={faShieldAlt}
                      className="admin-indicator"
                    />
                  )}
                </span>
              </div>
              <button onClick={handleProfileClick} className="dropdown-item">
                <FontAwesomeIcon icon={faUserEdit} /> <span>Edit Profile</span>
              </button>
              <button onClick={handleLogout} className="dropdown-item">
                <FontAwesomeIcon icon={faSignOutAlt} /> <span>Logout</span>
              </button>
            </>
          ) : (
            <>
              <button onClick={handleLoginClick} className="dropdown-item">
                <FontAwesomeIcon icon={faSignInAlt} /> <span>Login</span>
              </button>
              <button onClick={handleRegisterClick} className="dropdown-item">
                <FontAwesomeIcon icon={faUserPlus} /> <span>Register</span>
              </button>
            </>
          )}
        </div>
      )}
    </div>
  );
}

export default AuthWrapper;
