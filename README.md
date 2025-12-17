# HappenHub

[![CI](https://github.com/artemshut/happen_hub/actions/workflows/ci.yml/badge.svg)](https://github.com/artemshut/happen_hub/actions)
[![Deploy on Fly.io](https://img.shields.io/badge/deployed%20on-Fly.io-purple?logo=fly.io)](https://fly.io/apps/happen-hub)
[![Ruby](https://img.shields.io/badge/Ruby-3.2.4-red.svg?logo=ruby)](https://www.ruby-lang.org/en/)

**Plan better. Connect smarter. Live socially.**  
A modern web app to plan events with friends, vote on dates, track attendance, and stay effortlessly connected — all in real-time.

![HappenHub Screenshot](public/happenhub_preview.png)

---

## 🎯 Purpose

**HappenHub** makes event planning with friends smooth, interactive, and enjoyable. Whether it's a weekend trip, a dinner party, or a study session — coordinate your crew with voting, suggestions, maps, and group invites. No spreadsheets. No endless messaging.

---

## ✨ Key Features

### 🔗 **Invite & Share**
- Invite friends to events with public profile links or QR codes
- Share your event page with anyone, even outside the platform

### 📅 **Smart Scheduling**
- Suggest multiple time slots
- Let friends vote on their availability (✅ Yes / ❓ Maybe / ❌ No)
- Automatically highlight the best option

### 🤝 **Group Collaboration**
- Create friend groups
- Invite entire groups to events in one click

### 📍 **Interactive Map Integration**
- Visualize event locations using **Google Maps API**
- Easily add or edit location data for your events

### 💬 **Real-time Comments**
- Chat and discuss right on the event page
- Comments update live using **Hotwire**

### 📸 **Media Sharing**
- Upload cover images and event galleries
- See all shared media in one stylish layout

### ❤️ **Suggestions & Voting**
- Suggest alternative dates or activities
- Vote or **like** suggestions with slick animations

### 👤 **Customizable Profiles**
- Add an avatar, public tag, and more
- Share your profile via public URL or QR code

---

## 🧠 Smart Invitation Availability

When a host tweaks event times, friends in the invite panel show a status badge so conflicts are obvious:

- `Free` – no overlapping commitments for the invitee.
- `Busy` – at least one overlapping event they have accepted.
- `Tentative` – overlaps exist but they have only responded `maybe`/`pending`.
- `Unknown` – insufficient time data to decide (either event times are missing or the invitee has incomplete records).

Badges and tooltips come from `InviteeAvailabilityService` and the invite preview Turbo frame in `EventsController#availability_preview`. For the full matrix and background see `docs/smart_invitation_availability.md`. The XP/mission system is documented in `docs/gamification.md`.

---

## 💻 Tech Stack

- **Ruby on Rails** 7
- **Hotwire (Turbo + Stimulus)**
- **Tailwind CSS** for sleek, modern styling
- **PostgreSQL** database
- **Devise** for authentication
- **Fly.io + GitHub Actions** for deployment

---

## 🚀 Getting Started (for Developers)

```bash
git clone https://github.com/yourusername/happenhub.git
cd happenhub
bundle install
bin/setup
# If you skip bin/setup, make sure to prep the Solid Queue database as well:
# bin/rails db:prepare db:queue:prepare
bin/dev
```

---

## 🗂️ Task Workflow with `backlog.md`

We manage ongoing development using `backlog.md` in the project root:

- Add unchecked bullets under **Backlog** in priority order.
- Move the current item to **In Progress** (mark it `[x]`) when you or the agent begin work.
- After review/merge, move the item to **Done** and note the PR or outcome.

See `docs/AGENT_WORKFLOW.md` for the full step-by-step guide to collaborating with the agent.

### Terminal helpers

```bash
# Show the full backlog with simple coloring
bin/backlog_ui

# Print the next task waiting in Backlog
bin/backlog_next

# Start a task: creates/switches branch and moves it to In Progress
bin/backlog_start HUB-001

# Finish a task: runs tests, pushes, opens PR (via gh), moves to Done
bin/backlog_finish HUB-001
```

The scripts expect task bullets in `backlog.md` to follow the `HUB-###` format.
`bin/backlog_finish` auto-detects a sensible test command (`BACKLOG_TEST_COMMAND`
env var overrides the default). Pull request creation uses the GitHub CLI when
available; otherwise it will prompt you to open the PR manually.
