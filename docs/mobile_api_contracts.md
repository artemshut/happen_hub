# Mobile API Contracts

This document captures the endpoints that the Flutter app relies on, along with the fields, caching headers, and status codes it can expect.

## `/api/v1/me`

- **Method:** `GET`
- **Auth:** `Authorization: Bearer <jwt>`
- **Response:** `200 OK`
  - `data.attributes` includes `first_name`, `last_name`, `handle` (alias for `username`), `tag`, `xp`, `badges`, `cosmetic_unlocks`, `theme_settings` (`preference`, `unlocked_themes`, `flags`), `fcm_token`, and `updated_at`.
  - `plan` object mirrors the dashboard (limits, feature list, counts).
- **Usage:** `updated_at` allows the client to decide when to refetch profile data.

## `/api/v1/events`

- **Method:** `GET`
- **Auth:** required.
- **Query params:**
  - `page` / `per_page` (defaults to 1 / 25, capped at 100).
  - `past=true` to pull historical events, otherwise upcoming.
  - `category_id` to scope to a category.
  - `updated_after=<ISO8601>` to request only rows whose `updated_at` is later than the supplied timestamp.
- **Response:** `200 OK`
  - JSON:API envelope with full event attributes/relationships that match the show endpoint (user, category, comments + comment authors, likes).
  - Each event includes `archived` (true when it has already ended) and a `summary` array (`time`, `location`, `participants`) for dashboard widgets.
  - `meta` includes pagination data (`current_page`, `total_pages`, etc.).
- **Headers:**
  - `ETag` and `Last-Modified` describe the returned page.
  - Clients may send `If-None-Match`/`If-Modified-Since` to receive `304 Not Modified`.
- **Errors:** `422 Unprocessable Entity` when `updated_after` is not a valid ISO8601 timestamp.

## `/api/v1/events/:id`

- **Method:** `GET`
- **Behavior:** Mirrors the collection payload (same attributes + `summary` array) so cached list entries can hydrate the detail screen with no shape changes.
- **Headers:** Also emits `ETag` and `Last-Modified` based on the event row; respects conditional GET headers (returns `304` when nothing changed).

## `/api/v1/groups`

- **Method:** `GET`
- **Query params:** `page`, `per_page`, `updated_after=<ISO8601>`.
- **Response:** `200 OK`
  - JSON:API payload with `id`, `name`, `description`, `updated_at`, `archived` (currently `false` placeholder), and embedded `members`.
  - Pagination metadata mirrors `/events`.
- **Caching:** Same `ETag`/`Last-Modified` headers + conditional GET support as `/events`.
- **Errors:** `422` on malformed `updated_after`.

## `/api/v1/groups/:id`

- **Method:** `GET`
- **Response:** Same shape + caching headers as the collection entries (`ETag`, `Last-Modified`, `304` on cache hits).

## `/api/v1/users/fcm_token`

- **Method:** `POST`
- **Payload:** Accepts either `{ "token": "<fcm>" }`, `{ "fcm_token": "<fcm>" }`, or `{ "apns_token": "<fcm>" }`.
  - Optional `platform` must be one of `ios`, `android`, or `web`.
- **Response:**
  - `200 OK` with `{ success: true, fcm_token, platform }`.
  - `422 Unprocessable Entity` when the token/platform is missing or invalid.
- **Notes:** Values update in-place so multiple devices remain in sync.

## `/api/v1/sessions`

- **Logout (`DELETE`)**
  - Clears the stored FCM token + platform before returning `200 OK`.
  - Clients should still discard their JWT locally; this ensures server-side push tokens are not reused after logout.

These contracts give the Flutter state layer deterministic envelopes, timestamps, and caching signals so refresh cycles are predictable and minimal.
