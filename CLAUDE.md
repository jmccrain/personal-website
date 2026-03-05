# CLAUDE.md — joshuamccrain.com

## Project Overview
Academic website for Joshua McCrain, Assistant Professor of Political Science at the University of Utah. Static site, no CMS, no client-side framework.

## Tech Stack
- **Astro 5.x** — static site generator
- **Tailwind CSS 4.x** — utility-first CSS with `@theme` directive for custom colors
- **js-yaml** — parses YAML data files at build time
- **@astrojs/sitemap** — auto-generates sitemap
- Deployment: GitHub Pages via GitHub Actions (`.github/workflows/deploy.yml`)

## Commands
```bash
npm run dev      # Start dev server (http://localhost:4321), hot reloads
npm run build    # Production build to dist/
npm run preview  # Preview production build locally
```

## File Structure
```
src/
├── data/
│   ├── publications.yaml    # All publications (peer-reviewed, editor-solicited, under review)
│   ├── grants.yaml          # External & internal grants
│   └── media.yaml           # Media coverage, public scholarship, awards
├── layouts/
│   └── BaseLayout.astro     # Shared HTML shell, dark mode init, Schema.org, SEO meta
├── components/
│   ├── Header.astro         # Sticky nav + mobile hamburger menu
│   ├── Footer.astro         # Contact info, obfuscated email
│   ├── ThemeToggle.astro    # Dark/light toggle (used twice: desktop + mobile nav)
│   ├── PublicationCard.astro      # Single publication display with keyword badges
│   └── PublicationFilter.astro    # Year + keyword filter (client-side vanilla JS)
├── pages/
│   ├── index.astro          # Home: bio, photo, research areas, recent pubs
│   ├── publications.astro   # All publications with filtering
│   ├── grants.astro         # Grants listing
│   ├── media.astro          # Media coverage & awards
│   └── cv.astro             # Embedded PDF viewer + download
└── styles/
    └── global.css           # Tailwind directives, custom color tokens, dark mode variant
public/
├── McCrain_CV.pdf
├── headshot.jpg             # User-provided photo
└── favicon.svg              # "JM" initials
```

## Pages
| Route | Page |
|-------|------|
| `/` | Home |
| `/publications/` | Publications (filterable) |
| `/grants/` | Grants |
| `/media/` | Media & Public Scholarship |
| `/cv/` | CV (PDF embed) |

## Color System (defined in `src/styles/global.css`)
- **Utah red**: `utah-red` (#CC0000), `utah-red-dark` (#A30000), `utah-red-light` (#EF4444 — for dark mode)
- **Carolina blue**: `carolina-blue` (#4B9CD3), `carolina-blue-dark` (#3A7FB5), `carolina-blue-light` (#7AB8E0)
- **Dark mode surfaces**: `surface-dark` (#1C2128), `surface-dark-raised` (#242B33), `surface-dark-border` (#353D47)
- **Dark mode text**: `text-dark-primary` (#D1D5DB), `text-dark-secondary` (#8B949E)

Dark mode uses class-based toggle (`document.documentElement.classList.toggle('dark')`) with localStorage persistence.

## Adding a New Publication
Edit `src/data/publications.yaml`, add entry under the appropriate section:
```yaml
- title: "Paper Title"
  authors: "Last, First, Joshua McCrain, and Others"
  journal: "Journal Name"
  year: 2026
  doi: "https://doi.org/..."
  preprint: ""
  abstract: "Brief abstract text."
  discipline: "Political Science"    # or "Public Policy" or "Criminology / Criminal Justice"
  keywords:
    - "Policing"                     # Subfield tag
  methods:
    - "Causal Inference"             # Optional methods tag
```
Push to trigger rebuild. No other files need editing.

## Keyword Taxonomy
**Tier 1 — Discipline** (solid color pill): Political Science, Public Policy, Criminology / Criminal Justice
**Tier 2 — Subfield** (outlined pill): Media & Politics, Legislative Politics, Lobbying & Interest Groups, Policing, Public Opinion, Representation, Health Policy, AI & Technology
**Tier 3 — Methods** (muted tag): Survey Experiments, Causal Inference, Text Analysis, Measurement

## Key Conventions
- Email is obfuscated everywhere: `data-u` + `data-d` attributes assembled by JS on click. No plain-text email in HTML.
- ThemeToggle is rendered twice (desktop + mobile). Uses class selectors, not IDs. Script deduplication via `window.__themeToggleInit`.
- Publication filtering is client-side vanilla JS (~50 lines) in PublicationFilter.astro.
- McCrain's name is auto-bolded in author lists via regex in page frontmatter.
- All `is:inline` scripts that query DOM elements use `DOMContentLoaded` wrapper.

## Known Issues
- Dropbox syncing can cause EBUSY errors on node_modules/.vite and dist/. Vite cache is redirected to TEMP dir in astro.config.mjs. node_modules and dist have `com.dropbox.ignored` attribute set.
- Build may exit with code 1 due to EBUSY on dist/chunks cleanup, but all pages generate correctly.
