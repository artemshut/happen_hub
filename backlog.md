# HappenHub Backlog

This markdown file is the single source of truth for outstanding development work.  
Each task lives in the **Backlog** section until the agent starts it. When work begins, move it to **In Progress**.  
When the work has been reviewed and merged, move it to **Done** and include a short note or PR link.

## In Progress

- _empty_

## Backlog

- [ ] HUB-007 Mobile deep link for shared links (mobile-deeplink)
  - On mobile browsers detect if the native app is installed and open it directly when a HappenHub URL is tapped.
  - Provide a graceful fallback (store link or continue in web) when the app is missing.
  - Cover invite/share URLs first; document approach for expanding to other routes.
- [ ] HUB-008 Sub-events data model & API (subevents-core)
  - Extend events with nested sub-events (title, start/end, optional location/notes) and expose CRUD endpoints via the API.
  - Ensure sub-events are ordered (by start time or explicit ordering) and scoped to their parent event.
  - Add serializer coverage and request specs for new endpoints.
- [ ] HUB-009 Event page timeline UI (subevents-ui)
  - Surface sub-events on the host & attendee event pages as a timeline (or alternate visual) showing each segment’s timing and details.
  - Provide creation/editing controls in the web UI with inline validation and a fallback layout for mobile.
  - Include system tests or view specs ensuring the timeline renders correctly with various numbers of sub-events.
- [ ] HUB-010 Mobile apps consume sub-events (subevents-mobile-api)
  - Expand mobile-facing API responses (event show/list) to include sub-event data and relevant metadata for rendering.
  - Provide versioning or capability flags so older app versions degrade gracefully.
  - Add request specs verifying sub-events appear in event payloads and respect authorization rules.

## Done

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
