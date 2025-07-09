# 📚 LexiForge

**A digital cut-up poetry generator powered by classic literature from Project Gutenberg**

LexiForge transforms classic texts into experimental poetry using the cut-up technique pioneered by William S. Burroughs. Import any book from Project Gutenberg's vast collection and generate unique, randomized verse compositions.

## ✨ Features

- 🌐 **Project Gutenberg Integration** - Import any of 60,000+ free books directly via API
- ✂️ **Cut-Up Poetry Generation** - Transform prose into experimental poetry using randomization
- 📖 **Source Text Management** - Store and organize your literary collection
- 🎨 **Clean, Modern Interface** - Intuitive web interface for seamless text manipulation
- 🔍 **Popular Classics** - Quick access to beloved works like Pride & Prejudice, Alice in Wonderland
- 📊 **Text Analytics** - View word counts and content previews

## 🚀 Quick Start

### Prerequisites

- Ruby 3.1.1
- Rails 7.1
- PostgreSQL (or SQLite for development)

### Installation

```bash
# Clone the repository
git clone https://github.com/danispinxo/lexiforge.git
cd lexiforge

# Install dependencies
bundle install

# Set up the database
rails db:create db:migrate

# Start the server
rails server
```

Visit `http://localhost:3000/source_texts` to begin importing texts!

## 📖 Usage

### Importing from Project Gutenberg

1. Navigate to the **Source Texts** page
2. Enter a Project Gutenberg ID (e.g., `1342` for Pride and Prejudice)
3. Click **Import Text** to fetch and store the book
4. The text is automatically cleaned of headers and footers

### Popular Book IDs to Try

| ID   | Title                             | Author             |
| :--- | :-------------------------------- | :----------------- |
| 1342 | Pride and Prejudice               | Jane Austen        |
| 11   | Alice's Adventures in Wonderland  | Lewis Carroll      |
| 74   | The Adventures of Tom Sawyer      | Mark Twain         |
| 1661 | The Adventures of Sherlock Holmes | Arthur Conan Doyle |
| 2701 | Moby Dick                         | Herman Melville    |
| 844  | The Importance of Being Earnest   | Oscar Wilde        |

### Generating Cut-Up Poetry

1. Click on any imported source text
2. Select **Generate Cut-Up Poem**
3. Watch as lines are shuffled to create experimental verse
4. Save your favorite generated poems

## 🛠️ Technical Architecture

### Services

- **ProjectGutenbergService** - Handles API integration with Project Gutenberg

  - Fetches metadata and plain text content
  - Cleans texts by removing Project Gutenberg headers/footers
  - Supports multiple text formats (UTF-8, ASCII)

- **CutUpGenerator** - Implements the literary cut-up technique
  - Splits text into lines
  - Randomizes order for experimental poetry
  - Preserves original formatting where possible

### Models

- **SourceText** - Stores imported literary works

  - Tracks Project Gutenberg IDs to prevent duplicates
  - Validates content presence and title
  - Associated with generated poems

- **Poem** - Stores generated cut-up poetry
  - Links to source text for traceability
  - Preserves creative output for review

## 🎨 The Cut-Up Technique

The cut-up technique is a literary method in which written text is cut up and rearranged to create new text. Originally developed by artist Brion Gysin and popularized by writer William S. Burroughs, this method reveals hidden meanings and creates unexpected juxtapositions.

LexiForge automates this process digitally, allowing you to:

- Experiment with classic literature in new ways
- Discover unexpected connections between passages
- Create unique poetic compositions from prose
- Explore the intersection of tradition and avant-garde

## 🔧 API Integration Details

### Project Gutenberg URLs

LexiForge attempts to fetch texts from multiple URL patterns:

```
/files/{id}/{id}-0.txt      # UTF-8 format
/files/{id}/{id}.txt        # ASCII format
/cache/epub/{id}/pg{id}.txt # Alternative format
```

### Text Cleaning Process

1. Remove Project Gutenberg licensing headers
2. Remove end-of-book metadata and footers
3. Normalize whitespace and line breaks
4. Preserve paragraph structure for better cut-up results

## 🚀 Deployment

### Docker

```bash
docker build -t lexiforge .
docker run -p 3000:3000 lexiforge
```

### Heroku

```bash
git push heroku main
heroku run rails db:migrate
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 Resources

- [Project Gutenberg](https://www.gutenberg.org/) - Source of public domain texts
- [Cut-up Technique](https://en.wikipedia.org/wiki/Cut-up_technique) - Literary background
- [Rails Guides](https://guides.rubyonrails.org/) - Framework documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Project Gutenberg for providing free access to classic literature
- William S. Burroughs and Brion Gysin for pioneering the cut-up technique
- The Rails community for excellent documentation and tools

---

_Transform the classics. Forge new poetry. Welcome to LexiForge._
