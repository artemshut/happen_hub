# HappenHub Backlog

This markdown file is the single source of truth for outstanding development work.  
Each task lives in the **Backlog** section until the agent starts it. When work begins, move it to **In Progress**.  
When the work has been reviewed and merged, move it to **Done** and include a short note or PR link.

## In Progress

- _empty_

## Backlog

- [ ] HUB-010 Mobile apps consume sub-events (subevents-mobile-api)
  - Expand mobile-facing API responses (event show/list) to include sub-event data and relevant metadata for rendering.
  - Provide versioning or capability flags so older app versions degrade gracefully.
  - Add request specs verifying sub-events appear in event payloads and respect authorization rules.
- [ ] HUB-011 Event checklists (event-checklists)
  - Allow hosts to create per-event task lists (item name, optional due date, assignee/owner).
  - Surface checklist progress on the event detail page with controls to add, edit, complete, or reorder items.
  - Refresh the event detail UI so checklist panels feel native (responsive layout, neon progress indicator, inline form + completion animations).
  - Provide API coverage so mobile apps can read/update checklists; include request specs and basic UI tests.
- [ ] HUB-012 Progress & status gamification (gamify-progress)
  - Introduce Host XP + level badges visible on profile cards and invites; award points for hosting milestones, on-time logistics, attendance goals.
  - Implement Rhythm Streaks for consecutive weeks hosting/attending; reset streak after configurable inactivity window.
  - Add a Crew Sync meter tracking collaborations with friends; full meters unlock cosmetic rewards.
- [ ] HUB-014 Collectibles & avatar flair (gamify-custom)
  - Create neon badge sets for key achievements (first midnight rave, 100+ attendance, etc.) and display them on profiles/share cards.
  - Unlock new colorways/themes for event pages and share cards as users progress; include optional custom glowing circles/frames around avatars.

## Done

- [x] HUB-007 Mobile deep link for shared links (mobile-deeplink)
  - Detect mobile visitors for shared invite pages and attempt to open the native app with deep links.
  - Added store fallbacks when the app isn't installed and web links for desktop users.
  - Structured helper + Stimulus logic to make future deep link expansions straightforward.
- [x] HUB-008 Sub-events data model & API (subevents-core)
  - Added SubEvent model + nested attributes, API controller/routes/serializer, and Stimulus-powered UI to manage timeline segments.
  - Event show page now renders a neon timeline with hide/show controls; editing allows dynamic add/remove with datepickers.
- [x] HUB-005 Sharing invite links / social previews
  - Added gradient share panels on event pages with copy & native share actions.
  - Delivered secure guest-facing invite pages backed by unique share tokens and lightweight view/share analytics.
- [x] HUB-006 Calendar day focus view (calendar-day-focus)
  - Default dashboard calendar widget to show today’s events in a compact single-day view.
  - Add an “Expand calendar” control that opens the full month/week experience inside a modal overlay.
  - Ensure the modal calendar stays in sync with the day view (shared data source, consistent styling).
- [x] HUB-004 Test coverage and documentation for smart invitations
  - Add request/service specs covering each availability state.
  - Update README or internal docs to explain how availability is calculated.
- [x] HUB-003 Display availability status in invite UI
  - Surface the computed status (with color/icon copy) wherever a host adds friends to an event.
  - Ensure the status updates reactively when the event time changes.
- [x] HUB-002 Implement backend availability checker for invites
  - Build a service or query that evaluates a friend’s availability for a target event based on their confirmed and tentative participations.
  - Expose the result through the API used when searching or selecting invitees.
- [x] HUB-001 Define smart invitation availability rules
  - See `docs/smart_invitation_availability.md` for the finalized status matrix and requirements.

### Tips
- Use short codes in parentheses (e.g., `feature-flags`) to make it easy to reference a task in conversations.
- Keep acceptance criteria or reference links below the item bullet (indent two spaces) if needed.
- Only the top unchecked item should be picked up by the agent unless you explicitly request another one.
- [x] HUB-013 Missions & checklist boosts (gamify-missions)
  - Auto-assigned missions for hosts, attendees, commenters, and friend-makers + XP/badge rewards.
  - Soundcheck checklist detection, RSVP/comment/friend hooks, profile dashboard (XP bar + badges), `/api/v1/missions` docs.
