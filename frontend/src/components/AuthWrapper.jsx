import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router-dom";
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

  return (
    <div className="auth-dropdown" ref={dropdownRef}>
      <button
        className="auth-dropdown-toggle"
        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
      >
        {user ? (
          <>
            <span className="user-email">{user.email}</span>
            <span className="dropdown-arrow">▼</span>
          </>
        ) : (
          <>
            <span>Account</span>
            <span className="dropdown-arrow">▼</span>
          </>
        )}
      </button>

      {isDropdownOpen && (
        <div className="auth-dropdown-menu">
          {user ? (
            <>
              <div className="dropdown-header">
                <span>Welcome, {user.email}</span>
              </div>
              <button onClick={handleLogout} className="dropdown-item">
                Logout
              </button>
            </>
          ) : (
            <>
              <button onClick={handleLoginClick} className="dropdown-item">
                Login
              </button>
              <button onClick={handleRegisterClick} className="dropdown-item">
                Register
              </button>
            </>
          )}
        </div>
      )}
    </div>
  );
}

export default AuthWrapper;
