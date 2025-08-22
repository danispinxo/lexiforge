import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faLock, faGlobe } from "../config/fontawesome";

function PrivacyToggle({
  isPublic,
  onChange,
  disabled = false,
  showLabels = true,
  contentType = "content",
}) {
  return (
    <div className="privacy-toggle-group">
      <div className="privacy-toggle-container">
        <button
          type="button"
          className={`privacy-toggle ${isPublic ? "public" : "private"}`}
          onClick={() => !disabled && onChange(!isPublic)}
          disabled={disabled}
          aria-label={`Set to ${isPublic ? "private" : "public"}`}
        >
          <div className="privacy-toggle-track">
            <div className="privacy-toggle-thumb">
              <FontAwesomeIcon icon={isPublic ? faGlobe : faLock} className="privacy-toggle-icon" />
            </div>
          </div>
        </button>

        {showLabels && (
          <div className="privacy-toggle-labels">
            <span className={`privacy-label-text ${!isPublic ? "active" : ""}`}>
              <FontAwesomeIcon icon={faLock} className="privacy-icon" />
              Private
            </span>
            <span className={`privacy-label-text ${isPublic ? "active" : ""}`}>
              <FontAwesomeIcon icon={faGlobe} className="privacy-icon" />
              Public
            </span>
          </div>
        )}
      </div>

      <div className="privacy-help">
        {isPublic
          ? `Other users will be able to see and ${
              contentType === "source text" ? "use this text" : "see this poem"
            }`
          : `Only you will be able to see and ${
              contentType === "source text" ? "use this text" : "see this poem"
            }`}
      </div>
    </div>
  );
}

export default PrivacyToggle;
