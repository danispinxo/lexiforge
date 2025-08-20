import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faUserPlus,
  faEnvelope,
  faLock,
  faEye,
  faEyeSlash,
  faSignInAlt,
  faExclamationTriangle,
  faUser,
  faIdCard,
} from "../config/fontawesome";
import { useAuth } from "../hooks/useAuth";

function Register() {
  const [email, setEmail] = useState("");
  const [username, setUsername] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showPasswordConfirmation, setShowPasswordConfirmation] =
    useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const { register } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    if (password !== passwordConfirmation) {
      setError("Passwords don't match");
      setLoading(false);
      return;
    }

    const result = await register({
      email,
      username,
      first_name: firstName,
      last_name: lastName,
      password,
      password_confirmation: passwordConfirmation,
    });

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

  const togglePasswordConfirmationVisibility = () => {
    setShowPasswordConfirmation(!showPasswordConfirmation);
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
              <FontAwesomeIcon icon={faUserPlus} className="auth-icon" />{" "}
              Register
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
              <label htmlFor="username">
                <FontAwesomeIcon icon={faUser} /> <span>Username</span>
              </label>
              <input
                type="text"
                id="username"
                name="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                disabled={loading}
                minLength={3}
                maxLength={30}
                pattern="[a-zA-Z0-9_]+"
                title="Username can only contain letters, numbers, and underscores"
                autoComplete="username"
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="firstName">
                  <FontAwesomeIcon icon={faIdCard} /> <span>First Name</span>
                </label>
                <input
                  type="text"
                  id="firstName"
                  name="firstName"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  required
                  disabled={loading}
                  maxLength={50}
                  autoComplete="given-name"
                />
              </div>

              <div className="form-group">
                <label htmlFor="lastName">
                  <FontAwesomeIcon icon={faIdCard} /> <span>Last Name</span>
                </label>
                <input
                  type="text"
                  id="lastName"
                  name="lastName"
                  value={lastName}
                  onChange={(e) => setLastName(e.target.value)}
                  required
                  disabled={loading}
                  maxLength={50}
                  autoComplete="family-name"
                />
              </div>
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
                  minLength={6}
                  autoComplete="new-password"
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

            <div className="form-group">
              <label htmlFor="passwordConfirmation">
                <FontAwesomeIcon icon={faLock} />
                <span>Confirm Password</span>
              </label>
              <div className="password-input-container">
                <input
                  type={showPasswordConfirmation ? "text" : "password"}
                  id="passwordConfirmation"
                  name="passwordConfirmation"
                  value={passwordConfirmation}
                  onChange={(e) => setPasswordConfirmation(e.target.value)}
                  required
                  disabled={loading}
                  minLength={6}
                  autoComplete="new-password"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={togglePasswordConfirmationVisibility}
                  disabled={loading}
                >
                  <FontAwesomeIcon
                    icon={showPasswordConfirmation ? faEyeSlash : faEye}
                  />
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
                  <FontAwesomeIcon icon={faUserPlus} className="fa-spin" />{" "}
                  <span>Creating account...</span>
                </>
              ) : (
                <>
                  <FontAwesomeIcon icon={faUserPlus} /> <span>Register</span>
                </>
              )}
            </button>
          </form>

          <div className="auth-switch">
            <p>
              Already have an account?{" "}
              <Link to="/login" className="btn-link">
                <FontAwesomeIcon icon={faSignInAlt} /> <span>Login here</span>
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Register;
