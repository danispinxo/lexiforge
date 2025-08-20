# LexiForge

A digital poetry generation platform that transforms classic literature from Project Gutenberg into experimental poetry using multiple avant-garde literary techniques. The application provides a comprehensive API and web interface for generating cut-up, erasure, mesostic, N+7, and snowball poetry from public domain texts.

## Core Architecture

### Backend Framework

- **Rails 7.1** with Ruby 3.2.2
- **PostgreSQL** database with Active Record ORM
- **RESTful API** design with JSON serialization
- **Active Admin** for content management
- **Devise** for user authentication

### Frontend Technology

- **React 18** with Vite build system
- **SCSS** for modular styling architecture
- **Context API** for state management
- **Responsive design** with CSS Grid and Flexbox

## Poetry Generation Techniques

### Cut-Up Poetry

The foundational technique pioneered by William S. Burroughs and Brion Gysin. The `CutUpGenerator` service:

- Extracts clean words from source text using regex filtering
- Implements configurable line generation with variable word counts
- Supports multiple output formats with customizable parameters
- Generates 12 lines by default with 6 words per line
- Applies randomization algorithms to create unexpected juxtapositions

### Erasure Poetry

Digital implementation of the erasure technique where words are selectively removed from source text. The `ErasureGenerator` service:

- Processes text in page-based segments for structured output
- Implements both traditional erasure and blackout poetry modes
- Uses word boundary detection for precise text manipulation
- Maintains original spacing and formatting during word removal
- Supports configurable retention rates (default: 8 words per 50-word page)
- Generates HTML output with CSS classes for visual presentation

### Blackout Poetry

A variant of erasure poetry where removed words are replaced with visual blocks. The system:

- Replaces eliminated words with Unicode block characters
- Applies CSS styling for visual blackout effects
- Preserves text structure while creating visual poetry
- Generates multiple pages with consistent formatting

### Mesostic Poetry

Implementation of John Cage's mesostic technique using spine words. The `MesosticGenerator` service:

- Requires a spine word input for poem generation
- Searches source text for words containing spine letters at specific positions
- Supports multi-word spine phrases with stanza separation
- Implements progressive text scanning to maintain poem flow
- Validates spine word compatibility with available vocabulary

### N+7 Poetry

Digital implementation of the Oulipo N+7 technique. The `NPlusSevenGenerator` service:

- Integrates with a comprehensive dictionary database
- Identifies nouns in source text using part-of-speech tagging
- Replaces nouns with dictionary entries offset by configurable distance
- Supports variable offset values (default: 7 positions)
- Preserves original text structure and formatting
- Implements fallback search algorithms for dictionary lookups

### Snowball Poetry

Implementation of the snowball technique where each line contains words of increasing length. The `SnowballGenerator` service:

- Groups words by character length for systematic selection
- Implements configurable minimum word length parameters
- Ensures word variety across different length categories
- Prevents word repetition using Set data structures
- Validates source text vocabulary diversity requirements

### KWIC (KeyWord In Context) Poetry

Implementation of the KWIC technique that creates poetry by showcasing a keyword in various contexts. The `KwicGenerator` service:

- Searches source text for all instances of a specified keyword
- Extracts surrounding context words for each keyword occurrence
- Configurable context window size for varying line lengths
- Removes duplicate lines to ensure unique perspectives
- Generates poems that explore how a single word functions across different contexts
- Supports case-insensitive keyword matching while preserving original text structure

## Data Models

### SourceText Model

- Stores imported Project Gutenberg content with metadata
- Implements unique constraints on Gutenberg IDs
- Associates with generated poems through foreign keys
- Provides content validation and text processing methods
- Supports full-text search and content analytics

### Poem Model

- Tracks generated poetry with technique classification
- Implements validation for allowed technique types
- Provides word count and line count analytics
- Supports content truncation and formatting utilities
- Integrates with Ransack for advanced querying

### DictionaryWord Model

- Stores comprehensive dictionary data for N+7 generation
- Implements part-of-speech tagging and categorization
- Provides efficient lookup algorithms for word replacement
- Supports fuzzy matching and fallback search strategies
- Enables systematic word substitution patterns

## API Endpoints

### Poetry Generation

- `POST /api/source_texts/:id/generate_cut_up` - Cut-up poetry generation
- `POST /api/source_texts/:id/generate_erasure` - Erasure poetry generation
- `POST /api/source_texts/:id/generate_snowball` - Snowball poetry generation
- `POST /api/source_texts/:id/generate_mesostic` - Mesostic poetry generation
- `POST /api/source_texts/:id/generate_n_plus_seven` - N+7 poetry generation

### Content Management

- `GET /api/poems` - Retrieve all generated poems
- `GET /api/poems/:id` - Retrieve specific poem details
- `POST /api/poems` - Create new poem entries
- `GET /api/source_texts` - Retrieve available source texts
- `GET /api/source_texts/:id` - Retrieve specific source text details

## Project Gutenberg Integration

The `ProjectGutenbergService` provides automated text import functionality:

- Fetches metadata and plain text content via HTTP requests
- Implements multiple URL patterns for different text formats
- Performs automatic text cleaning and formatting
- Removes Project Gutenberg headers, footers, and metadata
- Supports UTF-8 and ASCII text encoding
- Implements error handling and retry logic

## Technical Features

### Content Processing

- Advanced text cleaning with regex pattern matching
- Word boundary detection and preservation
- Unicode character handling and normalization
- Configurable content filtering and validation

### Performance Optimization

- Database indexing on frequently queried fields
- Efficient word lookup algorithms
- Caching strategies for dictionary operations
- Optimized text processing pipelines

### Security Implementation

- Input validation and sanitization
- CORS configuration for cross-origin requests
- Authentication and authorization controls
- Parameterized queries to prevent injection attacks

### Scalability Considerations

- Modular service architecture for easy extension
- Configurable generation parameters
- Database optimization for large text processing
- Memory-efficient text manipulation algorithms

## Literary Context

The application implements five major experimental poetry techniques from the 20th century avant-garde movement:

1. **Cut-up** (1950s-60s) - William S. Burroughs and Brion Gysin's randomization technique
2. **Erasure** (1960s-present) - Selective word removal to reveal hidden meanings
3. **Mesostic** (1960s-70s) - John Cage's spine word technique
4. **N+7** (1960s) - Oulipo's systematic word replacement method
5. **Snowball** (1960s) - Progressive word length patterns

Each technique is implemented with respect to its original literary principles while leveraging modern computational capabilities for automated generation and analysis.
