# HappenHub Backlog

This markdown file is the single source of truth for outstanding development work.  
Each task lives in the **Backlog** section until the agent starts it. When work begins, move it to **In Progress**.  
When the work has been reviewed and merged, move it to **Done** and include a short note or PR link.

## In Progress
- [x] HUB-002 Implement backend availability checker for invites
  - Build a service or query that evaluates a friend’s availability for a target event based on their confirmed and tentative participations.
  - Expose the result through the API used when searching or selecting invitees.

## Backlog
- [ ] HUB-003 Display availability status in invite UI
  - Surface the computed status (with color/icon copy) wherever a host adds friends to an event.
  - Ensure the status updates reactively when the event time changes.
- [ ] HUB-004 Test coverage and documentation for smart invitations
  - Add request/service specs covering each availability state.
  - Update README or internal docs to explain how availability is calculated.

## Done

- [x] HUB-001 Define smart invitation availability rules
  - See `docs/smart_invitation_availability.md` for the finalized status matrix and requirements.

### Tips
- Use short codes in parentheses (e.g., `feature-flags`) to make it easy to reference a task in conversations.
- Keep acceptance criteria or reference links below the item bullet (indent two spaces) if needed.
- Only the top unchecked item should be picked up by the agent unless you explicitly request another one.
