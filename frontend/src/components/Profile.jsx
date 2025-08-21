import { useState, useEffect } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { VALIDATION } from "../constants";
import {
  faUser,
  faIdCard,
  faEnvelope,
  faLock,
  faEye,
  faEyeSlash,
  faExclamationTriangle,
  faCheckCircle,
  faUserEdit,
  faKey,
  faImage,
} from "../config/fontawesome";
import { useAuth } from "../hooks/useAuth";
import { authAPI } from "../services/api";

function Profile() {
  const { user, updateUser } = useAuth();
  const [loading, setLoading] = useState(false);
  const [profileError, setProfileError] = useState("");
  const [profileSuccess, setProfileSuccess] = useState("");
  const [passwordError, setPasswordError] = useState("");
  const [passwordSuccess, setPasswordSuccess] = useState("");
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const [profileData, setProfileData] = useState({
    username: "",
    first_name: "",
    last_name: "",
    bio: "",
  });

  const [passwordData, setPasswordData] = useState({
    current_password: "",
    new_password: "",
    confirm_password: "",
  });

  useEffect(() => {
    if (user) {
      setProfileData({
        username: user.username || "",
        first_name: user.first_name || "",
        last_name: user.last_name || "",
        bio: user.bio || "",
      });
    }
  }, [user]);

  const handleProfileSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setProfileError("");
    setProfileSuccess("");

    try {
      const response = await authAPI.updateProfile(profileData);
      if (response.data.success) {
        setProfileSuccess("Profile updated successfully!");
        updateUser(response.data.user);
      } else {
        setProfileError(response.data.message || "Failed to update profile");
      }
    } catch (error) {
      setProfileError(error.response?.data?.message || "Failed to update profile");
    }

    setLoading(false);
  };

  const handlePasswordSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setPasswordError("");
    setPasswordSuccess("");

    if (passwordData.new_password !== passwordData.confirm_password) {
      setPasswordError("New passwords don't match");
      setLoading(false);
      return;
    }

    try {
      const response = await authAPI.changePassword({
        current_password: passwordData.current_password,
        new_password: passwordData.new_password,
      });

      if (response.data.success) {
        setPasswordSuccess("Password changed successfully!");
        setPasswordData({
          current_password: "",
          new_password: "",
          confirm_password: "",
        });
      } else {
        setPasswordError(response.data.message || "Failed to change password");
      }
    } catch (error) {
      setPasswordError(error.response?.data?.message || "Failed to change password");
    }

    setLoading(false);
  };

  const handleProfileChange = (field, value) => {
    setProfileData((prev) => ({ ...prev, [field]: value }));
  };

  const handlePasswordChange = (field, value) => {
    setPasswordData((prev) => ({ ...prev, [field]: value }));
  };

  if (!user) {
    return (
      <div className="profile-page">
        <div className="profile-container">
          <p>Please log in to view your profile.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="profile-page">
      <div className="profile-container">
        <h1 className="profile-title">
          <FontAwesomeIcon icon={faUserEdit} /> Your Profile
        </h1>

        <div className="profile-header">
          <div className="avatar-section">
            <img src={user.gravatar_url} alt={`${user.full_name} avatar`} className="user-avatar" />
            <div className="avatar-info">
              <h2>{user.full_name}</h2>
              <p className="user-email">
                <FontAwesomeIcon icon={faEnvelope} /> {user.email}
              </p>
              <p className="gravatar-note">
                <FontAwesomeIcon icon={faImage} /> Avatar powered by{" "}
                <a href="https://gravatar.com" target="_blank" rel="noopener noreferrer">
                  Gravatar
                </a>
              </p>
            </div>
          </div>
        </div>

        <div className="profile-section">
          <h2>
            <FontAwesomeIcon icon={faUser} /> Edit Profile
          </h2>

          {profileError && (
            <div className="error-message">
              <FontAwesomeIcon icon={faExclamationTriangle} className="error-icon" />
              {profileError}
            </div>
          )}

          {profileSuccess && (
            <div className="success-message">
              <FontAwesomeIcon icon={faCheckCircle} className="success-icon" />
              {profileSuccess}
            </div>
          )}

          <form onSubmit={handleProfileSubmit} className="profile-form">
            <div className="form-group">
              <label htmlFor="username">
                <FontAwesomeIcon icon={faUser} /> <span>Username</span>
              </label>
              <input
                type="text"
                id="username"
                name="username"
                value={profileData.username}
                onChange={(e) => handleProfileChange("username", e.target.value)}
                required
                disabled={loading}
                minLength={VALIDATION.USERNAME.MIN_LENGTH}
                maxLength={VALIDATION.USERNAME.MAX_LENGTH}
                pattern={VALIDATION.USERNAME.PATTERN}
                title={VALIDATION.USERNAME.TITLE}
              />
            </div>

            <div className="form-group">
              <label htmlFor="first_name">
                <FontAwesomeIcon icon={faIdCard} /> <span>First Name</span>
              </label>
              <input
                type="text"
                id="first_name"
                name="first_name"
                value={profileData.first_name}
                onChange={(e) => handleProfileChange("first_name", e.target.value)}
                required
                disabled={loading}
                maxLength={VALIDATION.NAME.MAX_LENGTH}
              />
            </div>

            <div className="form-group">
              <label htmlFor="last_name">
                <FontAwesomeIcon icon={faIdCard} /> <span>Last Name</span>
              </label>
              <input
                type="text"
                id="last_name"
                name="last_name"
                value={profileData.last_name}
                onChange={(e) => handleProfileChange("last_name", e.target.value)}
                required
                disabled={loading}
                maxLength={VALIDATION.NAME.MAX_LENGTH}
              />
            </div>

            <div className="form-group">
              <label htmlFor="bio">
                <FontAwesomeIcon icon={faUser} /> <span>Bio</span>
              </label>
              <textarea
                id="bio"
                name="bio"
                value={profileData.bio}
                onChange={(e) => handleProfileChange("bio", e.target.value)}
                disabled={loading}
                maxLength={VALIDATION.BIO.MAX_LENGTH}
                rows={4}
                placeholder="Tell us a bit about yourself..."
              />
              <small className="char-count">
                {profileData.bio.length}/{VALIDATION.BIO.MAX_LENGTH} characters
              </small>
            </div>

            <button type="submit" disabled={loading} className="btn btn-primary">
              {loading ? (
                <>
                  <span>Saving...</span>
                </>
              ) : (
                <>
                  <span>Save Profile</span>
                </>
              )}
            </button>
          </form>
        </div>

        <div className="profile-section">
          <h2>
            <FontAwesomeIcon icon={faKey} /> Change Password
          </h2>

          {passwordError && (
            <div className="error-message">
              <FontAwesomeIcon icon={faExclamationTriangle} className="error-icon" />
              {passwordError}
            </div>
          )}

          {passwordSuccess && (
            <div className="success-message">
              <FontAwesomeIcon icon={faCheckCircle} className="success-icon" />
              {passwordSuccess}
            </div>
          )}

          <form onSubmit={handlePasswordSubmit} className="password-form">
            <div className="form-group">
              <label htmlFor="current_password">
                <FontAwesomeIcon icon={faLock} /> <span>Current Password</span>
              </label>
              <div className="password-input-container">
                <input
                  type={showCurrentPassword ? "text" : "password"}
                  id="current_password"
                  name="current_password"
                  value={passwordData.current_password}
                  onChange={(e) => handlePasswordChange("current_password", e.target.value)}
                  required
                  disabled={loading}
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                  disabled={loading}
                >
                  <FontAwesomeIcon icon={showCurrentPassword ? faEyeSlash : faEye} />
                </button>
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="new_password">
                <FontAwesomeIcon icon={faLock} /> <span>New Password</span>
              </label>
              <div className="password-input-container">
                <input
                  type={showNewPassword ? "text" : "password"}
                  id="new_password"
                  name="new_password"
                  value={passwordData.new_password}
                  onChange={(e) => handlePasswordChange("new_password", e.target.value)}
                  required
                  disabled={loading}
                  minLength={VALIDATION.PASSWORD.MIN_LENGTH}
                  autoComplete="new-password"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowNewPassword(!showNewPassword)}
                  disabled={loading}
                >
                  <FontAwesomeIcon icon={showNewPassword ? faEyeSlash : faEye} />
                </button>
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="confirm_password">
                <FontAwesomeIcon icon={faLock} /> <span>Confirm New Password</span>
              </label>
              <div className="password-input-container">
                <input
                  type={showConfirmPassword ? "text" : "password"}
                  id="confirm_password"
                  name="confirm_password"
                  value={passwordData.confirm_password}
                  onChange={(e) => handlePasswordChange("confirm_password", e.target.value)}
                  required
                  disabled={loading}
                  minLength={VALIDATION.PASSWORD.MIN_LENGTH}
                  autoComplete="new-password"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  disabled={loading}
                >
                  <FontAwesomeIcon icon={showConfirmPassword ? faEyeSlash : faEye} />
                </button>
              </div>
            </div>

            <button type="submit" disabled={loading} className="btn btn-primary">
              {loading ? (
                <>
                  <span>Changing Password...</span>
                </>
              ) : (
                <>
                  <span>Change Password</span>
                </>
              )}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default Profile;
