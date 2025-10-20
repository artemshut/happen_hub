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
bin/dev
