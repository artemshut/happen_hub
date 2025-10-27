# Smart Invitation Availability Rules

Task HUB-001 establishes the rules we will use when surfacing a friend’s
availability while they are being invited to a new event. The output below
defines the status values, how they are computed, and the data requirements the
next implementation tasks (HUB-002+) should follow.

## Status Values

| Status    | When it applies                                                                                                           | UI intent                          |
|-----------|---------------------------------------------------------------------------------------------------------------------------|------------------------------------|
| `free`    | No overlapping events where the invitee has RSVP’d `accepted` or `maybe`. Declined/pending invitations are ignored.      | Safe to invite – no known clashes. |
| `busy`    | At least one overlapping event with RSVP `accepted`.                                                                      | Invitee is already committed.      |
| `tentative` | No `accepted` overlaps, but at least one overlapping event with RSVP `maybe` (or `pending` if we choose to show it).    | Possible conflict – user should confirm. |
| `unknown` | Either the invitee has no RSVP/friendship record yet, or one of the events involved has incomplete time data.             | We could not determine availability. |

### Notes

* **Pending participations**: pending means the user has been invited but not
  responded. Treat it the same as `maybe` only if the product team wants to
  warn when a response is outstanding. For now we categorize it as `tentative`
  to avoid promising the user is free.
* **Declined participations**: always ignored – the user already said no.
* **Past events**: events whose `end_time` is in the past should not affect the
  availability for a future event.

## Time Window Comparison

* Events are defined with `start_time` and `end_time`. They may span multiple
  days.
* Two events overlap when both times satisfy:

  ```text
  existing.start_time < new_event.end_time &&
  existing.end_time   > new_event.start_time
  ```

  (Inclusive/exclusive: we treat back-to-back events as non-overlapping when
  one ends exactly when the next begins.)

* Always compare using UTC (`Time.zone`) to avoid time-zone drift. Persisted
  values are ActiveSupport time-with-zone objects, so converting both times to
  UTC before comparison is safest.

## Data Requirements

* We rely on `EventParticipation` records to drive availability.
  * `accepted` or `maybe/pending` are the only statuses considered conflicts.
  * Query against `event_participations` joined with `events` so we can inspect
    the time window.
* Visibility rules should be respected:
  * An invitee might belong to private events we can still see because they are
    the participant in question. When evaluating availability we should not
    leak other attendees, only the fact that a conflict exists.
* If an event is missing `end_time`, treat availability as `unknown` (and log
  the data issue).

## Suggested Service Output

When HUB-002 implements the backend checker, it should return a structured
payload similar to:

```json
{
  "status": "tentative",
  "conflicts": [
    {
      "event_id": 42,
      "title": "Monthly board game night",
      "start_time": "2025-02-04T18:00:00Z",
      "end_time": "2025-02-04T21:00:00Z",
      "rsvp_status": "maybe"
    }
  ]
}
```

The UI can then show a badge (“Tentative – responds to board game night”) while
still allowing the host to proceed with the invite.

## Follow-Up Tasks

* HUB-002 will implement the actual query/service returning these statuses.
* HUB-003 will render badges and surfaces in the invitation UI.
* HUB-004 ensures we cover this behaviour with request/service tests and
  document the logic in user-facing docs.
