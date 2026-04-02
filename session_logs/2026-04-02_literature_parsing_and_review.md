# Session Log: 2026-04-02 — Literature Parsing and CHI Applications Review

## What Was Done

### 1. Parsed 14 New PDFs to Markdown
- Ran `opendataloader_pdf` on `literature/to_be_processed/` → `literature/processed/`
- 14 new markdowns created (2 already existed: Kleinfeld, Overcriminalization2)
- New papers include: Chamlin & Cochran (2006), Espeland (2007), Scott (1998), Andresen & Malleson (2010), Rosenfeld (2009), and others spanning criminology, measurement theory, and political economy

### 2. CHI Literature Applications Review
- Created `docs/CHI_Literature_Applications_Review.md` — in-depth review of 25 CHI and related papers
- Organized by application type: trend analysis, hotspots vs. harmspots, victim/offender concentration, intervention evaluation, operational prioritization, methodological critiques
- Extracted detailed methodology, data, sample sizes, statistical methods, and key findings for each paper
- Identified three open gaps the NYC CHI can fill: (1) robustness of targeting to specification, (2) gun violence substitution methodology, (3) bridging CHI and composite indicator literatures
- Embedded TODO: investigate NYPD directed patrol / transit patrol deployment data to test harm vs. count prioritization

### 3. Housekeeping
- Updated `.gitignore` to exclude `*.csv`, `*.pdf`, `*.DS_Store`
- Removed `.DS_Store` from git tracking

## Files Created
- `docs/CHI_Literature_Applications_Review.md`
- `session_logs/2026-04-02_literature_parsing_and_review.md`
- 14 new markdown files in `literature/processed/`

## Files Modified
- `.gitignore` — added CSV, PDF, DS_Store exclusions

## Key Decisions
- Statutory-midpoint CHIs (like this project's) are resistant to the Lewis et al. (2024) feedback loop critique — important for positioning
- The strongest "bones" for the paper: block-level harm concentration (extending Weinborn), robustness testing (novel), gun violence substitution (novel)

## Open Questions / Next Steps
- Can NYPD directed patrol or transit patrol deployment data be obtained? If so, test whether deployments reflect harm or count prioritization
- Consider which 2-3 application types to combine for the paper's empirical section
