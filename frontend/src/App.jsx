import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import SourceTexts from "./components/SourceTexts";
import SourceTextDetail from "./components/SourceTextDetail";
import Poems from "./components/Poems";
import PoemDetail from "./components/PoemDetail";
import "./App.css";

function App() {
  return (
    <Router>
      <div className="app">
        <header className="app-header">
          <h1>LexiForge</h1>
          <nav>
            <Link to="/source-texts">Source Texts</Link>
            <Link to="/poems">Poems</Link>
          </nav>
        </header>

        <main className="app-main">
          <Routes>
            <Route path="/" element={<SourceTexts />} />
            <Route path="/source-texts" element={<SourceTexts />} />
            <Route path="/source-texts/:id" element={<SourceTextDetail />} />
            <Route path="/poems" element={<Poems />} />
            <Route path="/poems/:id" element={<PoemDetail />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
