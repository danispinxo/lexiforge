import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faBook, faPenNib } from "./config/fontawesome";
import { AuthProvider } from "./contexts/AuthContext.jsx";
import { useAuth } from "./hooks/useAuth";
import AuthWrapper from "./components/AuthWrapper";
import Login from "./components/Login";
import Register from "./components/Register";
import SourceTexts from "./components/SourceTexts";
import SourceTextDetail from "./components/SourceTextDetail";
import SourceTextEdit from "./components/SourceTextEdit";
import Poems from "./components/Poems";
import PoemDetail from "./components/PoemDetail";
import PoemEdit from "./components/PoemEdit";
import MySourceTexts from "./components/MySourceTexts";
import MyPoems from "./components/MyPoems";
import Profile from "./components/Profile";
import NotFound from "./components/NotFound";
import "./styles/App.scss";

function AppContent() {
  const { user } = useAuth();

  return (
    <div className="app">
      <header className="app-header">
        <div className="header-left">
          <Link to="/" className="logo">
            <h1>LexiForge</h1>
          </Link>
        </div>
        <nav>
          <Link to="/source-texts" className="nav-link">
            <FontAwesomeIcon icon={faBook} /> <span>Public Source Texts</span>
          </Link>
          <Link to="/poems" className="nav-link">
            <FontAwesomeIcon icon={faPenNib} /> <span>Public Poems</span>
          </Link>
          {user && (
            <>
              <Link to="/my-source-texts" className="nav-link nav-link-private">
                <FontAwesomeIcon icon={faBook} /> <span>My Source Texts</span>
              </Link>
              <Link to="/my-poems" className="nav-link nav-link-private">
                <FontAwesomeIcon icon={faPenNib} /> <span>My Poems</span>
              </Link>
            </>
          )}
        </nav>
        <div className="auth-section">
          <AuthWrapper />
        </div>
      </header>

      <main className="app-main">
        <Routes>
          <Route path="/" element={<SourceTexts />} />
          <Route path="/source-texts" element={<SourceTexts />} />
          <Route path="/source-texts/:id" element={<SourceTextDetail />} />
          <Route path="/source-texts/:id/edit" element={<SourceTextEdit />} />
          <Route path="/my-source-texts" element={<MySourceTexts />} />
          <Route path="/poems" element={<Poems />} />
          <Route path="/poems/:id" element={<PoemDetail />} />
          <Route path="/poems/:id/edit" element={<PoemEdit />} />
          <Route path="/my-poems" element={<MyPoems />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <AppContent />
      </Router>
    </AuthProvider>
  );
}

export default App;
