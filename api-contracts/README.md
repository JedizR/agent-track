# api-contracts/

API contracts live here. Claude writes them before any Backend or Frontend agent starts work.

---

## Why contracts come first

Agents produce much better output when they have a contract to follow. Without one, Backend guesses the shape of the response and Frontend guesses the shape of the request — and they rarely agree. Writing the contract takes 5 minutes and saves a full round-trip of fixes.

---

## Naming

```
{feature}.md
```

Examples:
```
auth.md
user-profile.md
subscription-billing.md
file-upload.md
```

---

## Contract format

Every contract covers these five sections. Skip none of them.

```markdown
# API Contract: {Feature Name}

## Endpoints

### POST /api/{resource}
**Auth required:** Yes / No
**Request body:**
\```json
{
  "field": "type — description"
}
\```
**Success response (201):**
\```json
{
  "field": "type — description"
}
\```
**Error responses:**
- 400 `invalid_input` — {when this fires}
- 401 `unauthorized` — {when this fires}
- 409 `conflict` — {when this fires}

---

## Shared types

\```typescript
interface {TypeName} {
  field: type; // description
}
\```

---

## Business rules

- {Rule 1 — written in plain English}
- {Rule 2}

---

## Out of scope

- {What this contract deliberately does NOT cover}
- {Deferred to a future contract}
```

---

## Example: auth contract

See [`auth.example.md`](auth.example.md) for a filled-out example you can use as a reference.

---

## Who reads this

- **Backend Engineer** — implements the endpoints exactly as specified
- **Frontend Engineer** — builds the client to match the request/response shapes
- **QA Engineer** — writes tests that assert the contract is honored

Claude owns this directory. Agents only read here, never write.
