# Event Checklists

Events can now contain multiple focused checklists (e.g., Hospitality, Decor, Logistics). Each checklist tracks its own progress bar and owns its own ordered set of tasks.

## Web UI

- Hosts create checklists from the “Event checklists” section on the event show page.
- Each checklist renders inside a Turbo frame, so renaming, reordering, or adding tasks happens inline without a full page reload.
- Tasks support assignees, optional due dates, completion toggles, and ordering controls.

## API

- `GET /api/v1/events/:event_id/checklists` returns all checklists + items.
- Nested routes under `/api/v1/events/:event_id/checklists/:checklist_id/items` expose CRUD/toggle/reorder.
- Event payloads now include `checklists` + `checklists.items` relationships for mobile clients.

See `spec/requests/api/v1/event_checklist_items_spec.rb` for coverage and usage examples.
