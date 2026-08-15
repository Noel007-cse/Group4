<div align="center">

<img src="https://img.shields.io/badge/Status-Mini%20Project-informational?style=for-the-badge" />
<img src="https://img.shields.io/badge/Team-Group%204-orange?style=for-the-badge" />
<img src="https://img.shields.io/badge/Release-Spacebook-blue?style=for-the-badge" />
<img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" />

<br /><br />

# 🏟️ Spacebook

### *Book your space, seat by seat.*

**A dynamic slot booking platform for turfs and halls — built as a mini project by Group 4.**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Structure](#-project-structure) • [Team](#-team)

</div>

---

## 🌱 About the Project

Spacebook is a full-stack booking platform that lets users search, browse, and reserve spaces — turfs, halls, and similar venues — with real-time seat/slot availability. Built as a mini project ("KUNJI Project") by Group 4, it combines a frontend booking experience with a dedicated backend service to handle listings, search, and reservations.

---

## ✨ Features

- **Seat/slot-based booking** — reserve specific seats or slots for turfs and halls
- **Space search** — search across available spaces with filtered results
- **My Spaces** — view and manage your own listed or booked spaces
- **Dark mode** — full dark theme support across the app
- **Dynamic availability** — real-time reflection of booked vs. open slots

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | `spacebook/` — _(update: e.g. React / Next.js)_ |
| **Backend** | `spacebook-backend/` — _(update: e.g. Node.js / Express / Django)_ |
| **Database** | _(update: e.g. MongoDB / PostgreSQL)_ |
| **Auth** | _(update, if applicable)_ |

> ℹ️ Since `spacebook-backend` is linked as a separate repository, update this table with the actual frameworks used in each — happy to refine once shared.

---

## 🚀 Getting Started

### Prerequisites

- Node.js ≥ 18 (or relevant runtime for your stack)
- A database instance (as required by `spacebook-backend`)

### 1. Clone the repository

```bash
git clone https://github.com/jeffmathew4545/Group4.git
cd Group4
```

### 2. Set up the backend

```bash
cd spacebook-backend
npm install
npm start
```

### 3. Set up the frontend

```bash
cd ../spacebook
npm install
npm start
```

### 4. Environment variables

Create a `.env` file in `spacebook-backend/` with your database and any API credentials:

```env
DATABASE_URL=your_database_url_here
PORT=5000
```

> ⚠️ Never commit your `.env` file — add it to `.gitignore`.

---

## 🏗 Project Structure

```
Group4/
├── spacebook/              # Frontend — search, seat booking, My Spaces, dark mode
├── spacebook-backend/       # Backend service (linked submodule/repo) — booking & search logic
└── README.md
```

---

## 📦 Releases

- **Spacebook** — Latest release.

---

## 🗺 Roadmap

- [ ] User authentication & profiles
- [ ] Payment integration for paid bookings
- [ ] Booking history & cancellations
- [ ] Admin dashboard for space owners
- [ ] Reviews and ratings for spaces

---

## 👥 Team

**Group 4 — Mini Project**

- [jeffmathew4545](https://github.com/jeffmathew4545)
- [SouravSasidharan](https://github.com/SouravSasidharan)

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Mini Project — Group 4**

</div>
