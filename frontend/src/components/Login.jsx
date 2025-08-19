import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faSignInAlt,
  faEnvelope,
  faLock,
  faEye,
  faEyeSlash,
  faUserPlus,
  faExclamationTriangle,
} from "../config/fontawesome";
import { useAuth } from "../hooks/useAuth";

function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    const result = await login({ email, password });

    if (result.success) {
      navigate("/");
    } else {
      setError(result.message);
    }

    setLoading(false);
  };

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  return (
    <div className="auth-page">
      <div className="auth-container">
        <div className="auth-form">
          <div className="auth-header">
            <Link to="/" className="back-link">
              Back to LexiForge
            </Link>
            <h2>
              <FontAwesomeIcon icon={faSignInAlt} className="auth-icon" /> Login
            </h2>
          </div>

          {error && (
            <div className="error-message">
              <FontAwesomeIcon
                icon={faExclamationTriangle}
                className="error-icon"
              />
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="email">
                <FontAwesomeIcon icon={faEnvelope} /> <span>Email</span>
              </label>
              <input
                type="email"
                id="email"
                name="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={loading}
                autoComplete="email"
              />
            </div>

            <div className="form-group">
              <label htmlFor="password">
                <FontAwesomeIcon icon={faLock} /> <span>Password</span>
              </label>
              <div className="password-input-container">
                <input
                  type={showPassword ? "text" : "password"}
                  id="password"
                  name="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  disabled={loading}
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={togglePasswordVisibility}
                  disabled={loading}
                >
                  <FontAwesomeIcon icon={showPassword ? faEyeSlash : faEye} />
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary"
            >
              {loading ? (
                <>
                  <FontAwesomeIcon icon={faSignInAlt} className="fa-spin" />{" "}
                  <span>Logging in...</span>
                </>
              ) : (
                <>
                  <FontAwesomeIcon icon={faSignInAlt} /> <span>Login</span>
                </>
              )}
            </button>
          </form>

          <div className="auth-switch">
            <p>
              Don't have an account?{" "}
              <Link to="/register" className="btn-link">
                <FontAwesomeIcon icon={faUserPlus} /> <span>Register here</span>
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Login;
