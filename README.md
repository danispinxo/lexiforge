# LexiForge

A digital poetry generation platform that transforms classic literature from Project Gutenberg into experimental poetry using multiple avant-garde literary techniques. The application provides a comprehensive API and web interface for generating cut-up, erasure, mesostic, N+7, and snowball poetry from public domain texts.

## Core Architecture

### Backend Framework

- **Rails 8** with Ruby 3.4.4
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

### Abecedarian Poetry

Implementation of the abecedarian technique where each line begins with successive letters of the alphabet. The `AbecedarianGenerator` service:

- Extracts words in order from source text for systematic processing
- Generates 26 lines corresponding to each letter of the alphabet
- Implements word position tracking to prevent repetition
- Supports configurable words per line parameters
- Creates structured alphabetical progression with randomized word selection
- Handles empty lines gracefully when suitable words aren't available

### Aleatory Poetry

Implementation of chance-based poetry generation using random word selection. The `AleatoryGenerator` service:

- Applies configurable randomness factors to word selection
- Implements multiple line length categories (very_short, short, medium, long, very_long)
- Uses Set data structures to prevent word repetition
- Supports weighted randomness for controlled chaos
- Generates poems through serendipitous word combinations
- Balances randomness with text coherence through intelligent word selection

### Alliterative Poetry

Implementation of alliterative poetry where lines are structured around repeated initial consonant sounds. The `AlliterativeGenerator` service:

- Filters words by specified alliteration letter
- Validates source text contains sufficient alliterative words
- Supports configurable line lengths and poem structure
- Implements letter validation and error handling
- Generates poems with consistent sonic patterns
- Creates rhythmic unity through consonant repetition

### Beautiful Outlaw Poetry

Implementation of the Beautiful Outlaw constraint where each stanza avoids letters from a hidden word. The `BeautifulOutlawGenerator` service:

- Requires a hidden word input for constraint generation
- Creates stanzas that progressively exclude letters from the hidden word
- Implements stanza-based structure with configurable lines per stanza
- Validates sufficient vocabulary for constraint requirements
- Generates poems through systematic letter exclusion
- Creates progressive linguistic limitations across stanzas

### Lipogram Poetry

Implementation of lipogram poetry where specific letters are systematically excluded. The `LipogramGenerator` service:

- Filters words by excluding specified letters
- Validates sufficient vocabulary after letter exclusion
- Supports configurable word counts and line lengths
- Implements letter validation and error handling
- Generates poems through systematic letter avoidance
- Creates constraint-based poetry with linguistic limitations

### Prisoners Constraint Poetry

Implementation of the prisoners constraint where only letters without ascenders or descenders are used. The `PrisonersConstraintGenerator` service:

- Filters words by typographic constraints (no ascenders/descenders)
- Supports multiple constraint types (no_ascenders, no_descenders, full_constraint)
- Implements probabilistic line length distribution
- Uses constrained character sets for word filtering
- Generates poems through extreme typographic limitations
- Creates unique rhythmic patterns through character restrictions

### Univocal Poetry

Implementation of univocal poetry where only words containing a single vowel are used. The `UnivocalGenerator` service:

- Filters words to contain only the specified vowel
- Validates sufficient vocabulary for vowel constraint
- Supports configurable word counts and line structures
- Implements vowel validation and error handling
- Generates poems through extreme phonetic limitations
- Creates distinctive sonic textures through vowel restriction

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

The application implements multiple experimental poetry techniques from the 20th century avant-garde movement, each with rich literary histories and notable practitioners:

### Cut-up Technique (1950s-1960s)

**Origins**: Developed by painter and writer Brion Gysin and popularized by William S. Burroughs.

**Literary Significance**: The cut-up method involves literally cutting up text and rearranging pieces to create new, often surprising juxtapositions and meanings. It challenges linear narrative and conventional meaning-making, embodying postmodern questioning of authorship and textual authority.

### Erasure Poetry (1960s-Present)

**Origins**: Rooted in concrete poetry and conceptual art movements, where existing texts become raw material for new creative works.

**Literary Significance**: Erasure reveals hidden meanings by removing words from source texts, creating new poems from the "negative space" of literature. The technique questions the permanence of textual meaning and explores the relationship between presence and absence in language.

### Blackout Poetry

**Origins**: A variant of erasure poetry where removed words are visually obscured rather than simply deleted.

**Literary Significance**: Creates visual poetry that emphasizes the materiality of text and the relationship between reading and seeing. The technique transforms pages into artistic objects where meaning emerges from both visible and hidden elements.

### Mesostic Poetry (1960s-1970s)

**Origins**: Developed by composer and artist John Cage as part of his exploration of chance operations and indeterminate structures in art.

**Literary Significance**: Uses "spine words" where each letter appears at specific positions within lines, creating vertical reading paths through horizontal text. Reflects Cage's interest in non-intentional art and the removal of personal taste from creative processes.

### N+7 Technique (1960s)

**Origins**: Created by Jean Lescure of Oulipo (Ouvroir de littérature potentielle), the French workshop for potential literature founded by Raymond Queneau and François Le Lionnais.

**Literary Significance**: Systematic replacement of nouns with words appearing seven positions later in the dictionary creates unexpected linguistic combinations that reveal the arbitrary nature of language. The technique explores how meaning shifts through methodical word substitution. Part of Oulipo's exploration of "potential literature," works created through mathematical and formal constraints rather than inspiration alone.

### Snowball Poetry (1960s)

**Origins**: Part of the concrete poetry movement where visual and structural elements of text become as important as semantic content.

**Literary Significance**: Creates visual and rhythmic patterns through systematic word length progression, exploring the relationship between form and meaning in poetry. The technique emphasizes the materiality of language and the visual aspects of text.

### KWIC (KeyWord In Context) Poetry (1950s-1960s)

**Origins**: Adapted from computational linguistics and early computer-assisted text analysis, where KWIC concordances were used to study word usage patterns in large text corpora.

**Literary Significance**: Explores how individual words function across different contexts, revealing semantic ranges and unexpected connections. The technique bridges computational text analysis with creative poetry, demonstrating how systematic approaches can generate artistic insights.

### Definitional Poetry

**Origins**: Replaces words with their dictionary definitions in a source text.

**Literary Significance**: Transforms dictionary definitions into poetry, exploring the relationship between denotative and connotative meaning. The technique reveals the poetic potential hidden within seemingly neutral, descriptive language.

### Found Poetry

**Origins**: Rooted in Marcel Duchamp's "readymades" and the broader modernist practice of incorporating existing materials into art.

**Literary Significance**: Elevates non-literary text to poetic status through selection and framing, questioning traditional notions of authorship and originality. The technique demonstrates that poetry exists latently in all forms of language.

### Reverse Lipogram

**Origins**: An inverse variation of the traditional lipogram constraint, where instead of avoiding specific letters, the text is restricted to using only a defined set of letters from the alphabet.

**Literary Significance**: Creates extreme linguistic constraints that force radical compression of vocabulary and meaning. The technique explores the boundaries of expression within severely limited phonetic palettes, often producing texts with unique sonic qualities and rhythmic patterns. By reversing the lipogram's logic of exclusion to one of inclusion, it demonstrates how creative constraints can generate unexpected linguistic possibilities.

### Abecedarian Poetry

**Origins**: One of the oldest poetic forms, dating back to ancient Hebrew psalms and Greek poetry, where each line or stanza begins with successive letters of the alphabet.

**Literary Significance**: Creates systematic structure through alphabetical progression, exploring the relationship between order and meaning. The technique demonstrates how formal constraints can generate both structure and surprise, as the alphabetical requirement forces unexpected word choices and line breaks. It bridges ancient poetic traditions with contemporary experimental practices.

### Aleatory Poetry

**Origins**: Rooted in the Dada and Surrealist movements of the early 20th century, where chance operations were used to generate art and literature.

**Literary Significance**: Embraces randomness and chance as creative forces, challenging traditional notions of authorial control and intentional meaning. The technique explores how serendipitous word combinations can generate unexpected insights and emotional resonances, demonstrating that meaning can emerge from non-intentional processes.

### Alliterative Poetry

**Origins**: Ancient poetic tradition found in Old English, Old Norse, and other Germanic languages, where lines are structured around repeated initial consonant sounds.

**Literary Significance**: Creates sonic unity and rhythmic patterns through consonant repetition, exploring the musical qualities of language. The technique demonstrates how sound patterns can generate meaning and emotional resonance independent of semantic content, bridging ancient oral traditions with contemporary experimental poetry.

### Beautiful Outlaw Poetry

**Origins**: A constraint-based technique where each stanza avoids using letters from a specific word, creating progressive linguistic limitations.

**Literary Significance**: Explores how systematic letter exclusion creates increasingly constrained vocabulary, forcing creative adaptation and compression of expression. The technique demonstrates how formal constraints can generate both limitation and liberation, as the narrowing of available words forces more precise and unexpected language choices.

### Lipogram Poetry

**Origins**: Ancient Greek technique where entire works are written without using a specific letter, most famously exemplified by Georges Perec's novel "La Disparition" written without the letter 'e'.

**Literary Significance**: Demonstrates how systematic letter exclusion creates both constraint and creativity, forcing writers to find alternative expressions and revealing the hidden dependencies of language. The technique explores the relationship between limitation and liberation in creative expression.

### Prisoners Constraint Poetry

**Origins**: Named after the constraint used by prisoners who could only write letters using letters that don't extend above or below the line (no ascenders or descenders).

**Literary Significance**: Explores how extreme formal constraints can generate unique linguistic possibilities and rhythmic patterns. The technique demonstrates how physical limitations can become creative catalysts, forcing innovative approaches to language and meaning within severely restricted parameters.

### Univocal Poetry

**Origins**: A constraint where poems are written using only words containing a single vowel, creating extreme phonetic limitations.

**Literary Significance**: Explores the sonic and rhythmic possibilities within severely limited phonetic palettes, demonstrating how constraint can generate unique musical qualities in language. The technique reveals the hidden musicality of words and creates distinctive sonic textures through vowel restriction.

---

Each technique implemented in LexiForge respects its original literary principles while leveraging computational capabilities for automated generation and analysis. The platform serves as both a creative tool and a digital archive of experimental poetry techniques, making these avant-garde methods accessible to contemporary writers and researchers.
