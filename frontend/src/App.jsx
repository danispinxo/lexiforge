import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { AuthProvider } from "./contexts/AuthContext.jsx";
import AuthWrapper from "./components/AuthWrapper";
import Login from "./components/Login";
import Register from "./components/Register";
import SourceTexts from "./components/SourceTexts";
import SourceTextDetail from "./components/SourceTextDetail";
import Poems from "./components/Poems";
import PoemDetail from "./components/PoemDetail";
import "./styles/App.scss";

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="app">
          <header className="app-header">
            <h1>LexiForge</h1>
            <nav>
              <Link to="/source-texts">Source Texts</Link>
              <Link to="/poems">Poems</Link>
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
              <Route path="/poems" element={<Poems />} />
              <Route path="/poems/:id" element={<PoemDetail />} />
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
            </Routes>
          </main>
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
