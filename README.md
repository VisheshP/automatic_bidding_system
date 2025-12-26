# Automatic Bidding System

A robust Rails-based application that allows sellers and buyers to engage in automated and manual bidding processes.

## 📋 Overview

This application allows:

- **Sellers**: To sign up, log in, and list items for bidding. Sellers can provide item details such as title, description, starting price, minimum selling price, and bidding times.

- **Buyers**: To sign up, log in, and view available items. Buyers can place either manual bids or auto-bids, where auto-bids are automatically incremented up to a maximum amount.

Internally, the system uses Redis to handle automatic bidding processes and ensures that bids are consistently updated in real-time.

## 🛠️ Setup

### Prerequisites

- **Ruby**: `3.2.1`
- **Rails**: `7.0.10`
- **Redis**: `4.0`
- **Database**: SQLite

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/VisheshP/automatic_bidding_system.git
cd automatic_bidding_system
```

### 2️⃣ Install Dependencies

```bash
bundle install
```

### 3️⃣ Setup the Database

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4️⃣ Start Redis

```bash
redis-server
```

### 5️⃣ Start the Rails Server

```bash
rails server
```

Visit `http://localhost:3000` to access the application.

### 6️⃣ Background Workers and Cron Jobs

To handle automated bidding, ensure Redis is running and then start the background worker:

```bash
bundle exec sidekiq
```

To run the cron job that processes auto-bids:

```bash
bundle exec rake auto_bid:consume
```

### 7️⃣ Running Tests

To ensure everything works as expected, run the RSpec tests:

```bash
bundle exec rspec
```

## ⚙️ Dependencies

- **Ruby**: `3.2.1`
- **Rails**: `7.0.10`
- **Redis**: `4.0`
- **Database**: SQLite

## 📈 Usage

- **Sellers** can create and manage auction items.
- **Buyers** can place manual or auto-bids on listed items.

## 📝 Testing

All critical functionalities are tested using RSpec. To run tests, simply execute the `rspec` command as shown above.

## 📄 License

This project is open-source.
