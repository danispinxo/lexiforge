import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faHome, faArrowLeft } from "../config/fontawesome";
import "../styles/components/_not-found.scss";

const NotFound = () => {
  return (
    <div className="not-found">
      <div className="not-found-content">
        <div className="error-code">404</div>
        <h1>Page Not Found</h1>
        <p>
          Sorry, the page you're looking for doesn't exist. It might have been
          moved, deleted, or you entered the wrong URL.
        </p>
        <div className="not-found-actions">
          <Link to="/" className="btn btn-primary">
            <FontAwesomeIcon icon={faHome} />
            <span>Go Home</span>
          </Link>
          <button
            onClick={() => window.history.back()}
            className="btn btn-secondary"
          >
            <FontAwesomeIcon icon={faArrowLeft} />
            <span>Go Back</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default NotFound;
