# Agent Workflow with `backlog.md`

This document explains how to drive an autonomous coding session using the repository’s `backlog.md` file.

## 1. Prepare the Backlog
1. Keep tasks in `backlog.md` under the **Backlog** heading as unchecked list items (`- [ ] Task`).
2. Put the most urgent item at the top; the agent will pick the first unchecked task by default.
3. Add optional detail or acceptance criteria on the lines beneath a task, indented by two spaces.

## 2. Kick Off a Task
1. Ensure no item lives under **In Progress**.
2. Move the top backlog item to **In Progress** and change it to checked (`- [x]`) so the agent knows it is claimed.
3. Start a conversation with the agent and reference the task’s short code or copy the bullet.

Example prompt:
```
Please work on the task marked `[x]` in the In Progress section of backlog.md (code: `active-admin-theme`).
```

## 3. During the Session
- The agent will work through the task, updating you with findings and code changes.
- If the work needs clarifications, add them directly below the bullet in `backlog.md` or provide them in chat.
- Keep only one item in **In Progress** to avoid context switching.

## 4. Wrapping Up
1. Review and test the changes locally.
2. When the task is accepted, move the bullet to **Done** and add a short note or PR link.
3. Clear the **In Progress** section so the next session can start fresh.

## 5. Common Commands
- `yarn build:css` – Rebuild Tailwind assets.
- `bin/rails test` – Run the Rails test suite.
- `bin/rails assets:precompile` – Verify production asset build.

> **Tip:** Commit frequently. Each task should ideally map to one commit or PR.
