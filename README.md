# LexiForge

**A digital cut-up poetry generator powered by classic literature from Project Gutenberg**

LexiForge transforms classic texts into experimental poetry using the cut-up technique pioneered by William S. Burroughs. Import any book from Project Gutenberg's vast collection and generate unique, randomized verse compositions.

## ✨ Features

- **Project Gutenberg Integration** - Import any of 60,000+ free books directly via API
- **Cut-Up Poetry Generation** - Transform prose into experimental poetry using randomization
- **Source Text Management** - Store and organize your literary collection
- **Clean, Modern Interface** - Intuitive web interface for seamless text manipulation
- **Popular Classics** - Quick access to beloved works like Pride & Prejudice, Alice in Wonderland
- **Text Analytics** - View word counts and content previews

## 🚀 Quick Start

### Prerequisites

- Ruby 3.1.1
- Rails 7.1
- PostgreSQL

### Installation

```bash
# Clone the repository
git clone https://github.com/danispinxo/lexiforge.git
cd lexiforge

# Copy environment variables
cp .env.example .env
# Edit .env with your configuration

# Install dependencies
bundle install

# Set up the database
rails db:create db:migrate db:seed

# Start the server
rails server
```

Visit `http://localhost:3000/source_texts` to begin importing texts!

### Environment Variables

Copy `env.example` to `.env` and configure the following variables:

- **Database**: `DATABASE_URL`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- **API**: `API_BASE_URL`, `FRONTEND_URL`
- **CORS**: `ALLOWED_ORIGINS` (comma-separated list)
- **Admin**: `ADMIN_EMAIL`, `ADMIN_PASSWORD`
- **Security**: `SECRET_KEY_BASE`, `RAILS_MASTER_KEY`

For production deployment, ensure all environment variables are properly set in your hosting platform.

## Usage

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

## Technical Architecture

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

## The Cut-Up Technique

The cut-up technique is a literary method in which written text is cut up and rearranged to create new text. Originally developed by artist Brion Gysin and popularized by writer William S. Burroughs, this method reveals hidden meanings and creates unexpected juxtapositions.

LexiForge automates this process digitally, allowing you to:

- Experiment with classic literature in new ways
- Discover unexpected connections between passages
- Create unique poetic compositions from prose
- Explore the intersection of tradition and avant-garde

## API Integration Details

### Project Gutenberg URLs

LexiForge attempts to fetch texts from multiple URL patterns:

```
/files/{id}/{id}-0.txt      # UTF-8 format
/files/{id}/{id}.txt        # ASCII format
/cache/epub/{id}/pg{id}.txt # Alternative format
```

## Deployment

### Production Setup

1. Set all required environment variables in your hosting platform
2. Ensure PostgreSQL and Redis are available
3. Run database migrations: `rails db:migrate`
4. Seed the database: `rails db:seed`
5. Set up SSL certificates for HTTPS
6. Configure your web server (nginx, Apache) to proxy to the Rails app

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up -d

# Or build production images
docker build -t lexiforge-api .
docker build -t lexiforge-frontend ./frontend
```

## Resources

- [Project Gutenberg](https://www.gutenberg.org/) - Source of public domain texts
- [Cut-up Technique](https://en.wikipedia.org/wiki/Cut-up_technique) - Literary method background
- [William S. Burroughs](https://en.wikipedia.org/wiki/William_S._Burroughs) - Cut-up technique pioneer
