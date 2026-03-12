# API Contract: Authentication

> Example contract — shows the format. Adapt for your project.

---

## Endpoints

### POST /api/auth/register
**Auth required:** No
**Request body:**
```json
{
  "email": "string — valid email, max 254 chars",
  "password": "string — 8–72 chars",
  "name": "string — display name, max 100 chars"
}
```
**Success response (201):**
```json
{
  "user": {
    "id": "string — UUID",
    "email": "string",
    "name": "string",
    "createdAt": "string — ISO 8601"
  },
  "token": "string — JWT access token, 15 min expiry",
  "refreshToken": "string — opaque token, 30 day expiry"
}
```
**Error responses:**
- 400 `invalid_input` — missing required fields or malformed email
- 409 `email_taken` — account with this email already exists

---

### POST /api/auth/login
**Auth required:** No
**Request body:**
```json
{
  "email": "string",
  "password": "string"
}
```
**Success response (200):**
```json
{
  "user": { "id": "string", "email": "string", "name": "string" },
  "token": "string — JWT access token",
  "refreshToken": "string"
}
```
**Error responses:**
- 400 `invalid_input` — missing fields
- 401 `invalid_credentials` — wrong email or password (same message for both — no enumeration)

---

### POST /api/auth/refresh
**Auth required:** No (uses refresh token)
**Request body:**
```json
{
  "refreshToken": "string"
}
```
**Success response (200):**
```json
{
  "token": "string — new JWT access token",
  "refreshToken": "string — rotated refresh token"
}
```
**Error responses:**
- 401 `invalid_token` — expired or revoked refresh token

---

### POST /api/auth/logout
**Auth required:** Yes
**Request body:**
```json
{
  "refreshToken": "string"
}
```
**Success response (204):** No body.

---

## Shared types

```typescript
interface AuthUser {
  id: string;        // UUID
  email: string;
  name: string;
  createdAt: string; // ISO 8601
}

interface AuthTokens {
  token: string;        // JWT, 15 min
  refreshToken: string; // opaque, 30 days
}
```

---

## Business rules

- Passwords are hashed with bcrypt (cost factor 12) — never stored in plain text
- Refresh tokens rotate on use — old token is invalidated immediately
- After 5 failed login attempts from the same IP within 10 minutes, return 429
- Email addresses are lowercased and trimmed before storage and lookup

---

## Out of scope

- OAuth / social login (separate contract: `auth-oauth.md`)
- Password reset flow (separate contract: `auth-password-reset.md`)
- Email verification (deferred to v1.1)
