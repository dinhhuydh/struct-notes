# StructNotes

Turn rough travel notes into structured, magazine-ready articles using AI.

## Features

- **Paste or upload** — paste text or upload a .docx file with your travel notes
- **AI-powered structuring** — converts notes into a structured article with sections, key facts, best-for/not-for callouts, and ethics notes
- **Source attribution** — every claim links back to the original notes for fact-checking
- **Template selection** — choose from Travel Experience, Hotel Review, or Food & Dining templates
- **Edit before publishing** — review and edit every field before saving
- **User accounts** — sign up, sign in, each user sees only their own articles
- **Usage limits** — configurable monthly generation limits per user

## Tech Stack

- Ruby on Rails 8.0
- SQLite (development) / PostgreSQL (production)
- Tailwind CSS
- Devise (authentication)
- Claude API via Anthropic Ruby SDK

## Setup

### Prerequisites

- Ruby 3.3+
- Node.js (for Tailwind CSS)
- An Anthropic API key

### Install

```bash
git clone <repo-url>
cd struct-notes
bundle install
rails db:migrate
rails db:seed
```

### Configure

Set environment variables:

```bash
export ANTHROPIC_API_KEY=sk-ant-your-key-here
export ANTHROPIC_MODEL=claude-sonnet-4-20250514  # optional, defaults to claude-sonnet-4-20250514
```

### Run

```bash
bin/dev
```

Visit http://localhost:3000

### Tests

```bash
rails test
```

## Deployment (Render.com Free Tier)

1. Push to a GitHub repo
2. On Render, click "New" > "Blueprint" and connect the repo
3. Render reads `render.yaml` and creates the web service + PostgreSQL database
4. Set environment variables in Render dashboard:
   - `RAILS_MASTER_KEY` — from `config/master.key`
   - `ANTHROPIC_API_KEY` — your Claude API key
5. Deploy

### Alternative: Fly.io

```bash
fly launch
fly secrets set ANTHROPIC_API_KEY=sk-ant-your-key-here
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)
fly deploy
```

## Edge Cases Handled

| Scenario | Handling |
|----------|---------|
| Invalid file format | Flash error, stays on form |
| File > 50 MB | Flash error before parsing |
| Notes too short (< 50 chars) | Flash error with guidance |
| Corrupted .docx | Flash error suggesting re-save |
| API key missing | Flash error to contact admin |
| API rate limited | Flash error to retry |
| API timeout (60s) | Flash error to retry |
| API bad response / invalid JSON | Flash error to retry |
| User at generation limit | Flash error with limit info |
| Accessing another user's articles | 404 Not Found |

## Project Structure

```
app/
  controllers/
    articles_controller.rb    # CRUD + generate + file validation
    pages_controller.rb       # Landing page
  models/
    article.rb               # Structured article with JSON fields
    template.rb              # LLM prompt templates
    user.rb                  # Devise auth + generation limits
  services/
    article_generator_service.rb  # Claude API integration
    docx_parser.rb               # .docx text extraction
  views/
    articles/                # index, new_upload, edit, show
    pages/                   # landing
    devise/                  # styled auth forms
```
