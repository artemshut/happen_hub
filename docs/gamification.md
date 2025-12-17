# Gamification & Missions

This document explains the XP/missions system that powers weekend missions, Soundcheck boosts, attendee incentives, and badge unlocks.

## Data model

- `missions` – catalog of mission templates.
  - `key` unique string (`weekend_host`, `soundcheck_ready`, `attend_social`, `comment_supporter`, etc.).
  - `category` (`weekend`, `soundcheck`, `custom`).
  - `target_value`, `reward_xp`, optional `reward_badge`, `metadata` hash (for checklist hints).
  - `auto_assign` – if true, every user automatically gets a `user_mission` record on sign in.
- `user_missions` – per-user assignment and progress.
  - `status` enum (`pending`, `in_progress`, `completed`, `expired`).
  - `progress`, `target_value`, optional `expires_at`/`completed_at`, `metadata` for audit.
- `users.xp`, `users.cosmetic_unlocks` – cumulative XP and array of unlocked badges (e.g., `{"badges": ["soundcheck-pro"]}`).

## Assignment lifecycle

1. **Auto-assign**: `ApplicationController` and `Api::V1::BaseController` call `current_user.ensure_missions_assigned!` whenever a user signs in, ensuring a `user_mission` row exists for each active auto-assignable mission.
2. **Progress ticks** (server-side services/hook points):
   - Event create/update: `Event#evaluate_missions!` invokes `Missions::ProgressService` (`weekend_host`) and `Missions::SoundcheckService` (`soundcheck_ready`).
   - RSVP accepted (web & API): `Missions::ProgressService.tick!(:attend_social, metadata: { event_id: ... })`.
   - Comment create (web & API): `tick!(:comment_supporter, metadata: { comment_id: ... })`.
3. **Completion**: `UserMission#increment!` clamps progress, updates status, and when `progress >= target_value` it marks the assignment `completed`, sets `completed_at`, and runs `Missions::RewardService` to grant XP and optional badges.

## Web surfaces

- **Profile dashboard** (`/profile`):
  - XP card shows total XP, current level (500 XP per level), progress bar to next level, and badge pills from `cosmetic_unlocks`.
  - “Current missions” deck (render `profiles/_mission_cards`) lists each `user_mission` with reward, description, progress bar, and status text.
- Event pages no longer show missions; hosts can check progress from their profile.

## Mobile/API integration

### Authentication

All endpoints live under `/api/v1` and require standard JWT (`Authorization: Bearer <token>`). `Api::V1::BaseController` ensures missions are auto-assigned before responses are returned.

### List assignments

`GET /api/v1/missions`

```http
GET /api/v1/missions
Authorization: Bearer <jwt>
Accept: application/json
```

Response (JSON:API) – simplified example:

```json
{
  "data": [
    {
      "type": "user_mission",
      "id": "42",
      "attributes": {
        "status": "in_progress",
        "progress": 1,
        "target_value": 3,
        "expires_at": null,
        "completed_at": null,
        "created_at": "2025-11-21T18:00:00Z",
        "mission": {
          "key": "attend_social",
          "title": "Show up & vibe",
          "description": "RSVP 'going' to three different events.",
          "category": "weekend",
          "reward_xp": 120,
          "reward_badge": null
        },
        "progress_ratio": 0.33
      }
    }
  ]
}
```

Additional notes:
- No `include` parameter needed; mission info is embedded in `mission` attribute.
- Rewards happen automatically when the server marks a mission completed; clients can poll this endpoint after relevant actions (e.g., after hitting the RSVP API) to surface “+XP” toasts.

### Other APIs

Existing endpoints already drive mission progress:
- `POST /api/v1/events/:id/rsvp` – RSVP status must be `accepted` for attendee mission increments.
- `POST /api/v1/events/:event_id/comments` – posting comments increments `comment_supporter`.
- Event creation/update flows happen server-side; mobile does not need to send extra payloads.

### Display suggestions (mobile)
- Surface the mission cards on a dashboard or profile screen, mapping `status` to visual states (`pending`, `in_progress`, `completed`, `expired`).
- Use `progress`/`target_value` or `progress_ratio` to render progress bars.
- Show XP totals (available via `GET /api/v1/me`, which already returns the user resource including `xp` and `cosmetic_unlocks`).

## Adding missions
- Seed via `db/seeds.rb` or Admin UI: set `auto_assign` true for missions that should attach to every user automatically.
- Hook into relevant actions and call `Missions::ProgressService.new(user).tick!(:your_key, increment: X, metadata: {...})`.
- Stagger XP rewards (default levels are 500 XP apart, adjustable in the XP card view).

## Tests
- `spec/models/user_mission_spec.rb` ensures progress/completion + reward service invocation.
- `spec/services/missions/progress_service_spec.rb` checks that ticking missions assigns/completes and grants XP.
- `spec/requests/api/v1/missions_spec.rb` validates the JSON response for `GET /api/v1/missions`.

Keep this document updated when adding new missions, reward types, or surfaces.
