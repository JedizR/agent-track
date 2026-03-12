# research/

Business Consultant output lives here. Run `make consult TASK="..."` to populate it.

---

## When to use the Consultant

Before committing to any of these, run a Consultant research task first:

- Pricing model or tier structure
- New market or geography
- Technology stack decision with significant trade-offs
- Regulatory compliance question
- Competitor positioning analysis
- Build vs. buy decision

The Consultant uses Gemini Pro with Google Search, so results are grounded in real, current data — not training-data guesses.

---

## Naming

```
{topic}-{unix-timestamp}.md
```

Examples:
```
saas-pricing-benchmarks-1741234567.md
stripe-vs-paddle-comparison-1741234567.md
gdpr-requirements-b2b-1741234567.md
competitor-analysis-project-management-1741234567.md
```

The timestamp links research back to a specific decision point. Use `$(date +%s)` to generate it.

---

## Running a research task

```bash
make consult TASK="What are the standard subscription tier structures for B2B
  project management tools in 2026? Compare per-seat vs flat-rate pricing.
  Cite real products and their current pricing pages."
```

Good research prompts have three parts:
1. **The question** — specific, not open-ended
2. **The framing** — what decision this informs
3. **What to cite** — ask for real companies, URLs, pricing pages

---

## After reading research

Don't act on research directly. Read it, make the architecture or business decision yourself, then write the api-contract or product spec that captures that decision. Research informs decisions — it doesn't replace them.

---

## Rate limits

The Consultant uses `gemini-2.5-pro` (100 requests/day on the free tier). Don't use it for routine coding tasks. Use it before major decision points — not per feature.

---

## Gitignore note

Research files are not gitignored by default. They're useful to commit — they record why decisions were made, which matters for future contributors. If a research file contains confidential competitive analysis you don't want public, add it to `.gitignore` manually.
