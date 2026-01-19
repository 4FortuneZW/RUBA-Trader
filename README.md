# RUBA Trader

Welcome to the RUBA Trader project.

## Project Overview

This project is a cryptocurrency trading bot that helps automate trading strategies and manage crypto portfolios, featuring a Discord bot interface for real-time monitoring, control, and alerts.

## 🎯 Key Features

### Discord Bot
- **Real-time Monitoring**: Live updates on trading activities and portfolio status
- **Command System**: Interactive slash commands for portfolio management and trading
- **Alert System**: Notifications for trade executions, price alerts, and risk warnings
- **Strategy Management**: Activate/deactivate trading strategies via Discord
- **Admin Controls**: Configuration management and system controls

### GitHub Automation
- **Auto-Push**: Automatically push configuration changes and bot state to GitHub
- **Auto-Pull**: Regularly sync with remote repository for updates
- **Conflict Resolution**: Intelligent handling of merge conflicts
- **CI/CD Integration**: GitHub Actions for deployment and testing

## 📚 Documentation

- [DISCORD_BOT_PLAN.md](DISCORD_BOT_PLAN.md) - Comprehensive Discord bot architecture and feature planning
- [GITHUB_AUTOMATION_GUIDE.md](GITHUB_AUTOMATION_GUIDE.md) - GitHub automation setup and configuration guide

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ or 20+
- Git
- PostgreSQL database (for production)
- Discord bot token
- GitHub account with repository access

### Quick Start

```bash
# Clone the repository
git clone https://github.com/4FortuneZW/RUBA-Trader.git
cd RUBA-Trader

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Set up database
npx prisma migrate dev

# Start the bot
npm start
```

### Discord Commands

#### Portfolio Commands
- `/portfolio` - Display current portfolio value and holdings
- `/balance` - Show account balance (USD and crypto)
- `/history [days]` - Show transaction history
- `/performance` - Display portfolio performance metrics

#### Trading Commands
- `/trade buy [symbol] [amount]` - Execute buy order
- `/trade sell [symbol] [amount]` - Execute sell order
- `/status [symbol]` - Get current price and market data
- `/strategy [name]` - Activate/deactivate trading strategies
- `/orders` - View open/closed orders

#### Alert Commands
- `/alert create [symbol] [condition] [value]` - Create price alert
- `/alert list` - List all active alerts
- `/alert remove [id]` - Remove an alert

#### Sync Commands
- `/sync push` - Push local changes to GitHub
- `/sync pull` - Pull changes from GitHub

## 🔧 Configuration

### Environment Variables

```bash
# Discord Bot
DISCORD_TOKEN=your_discord_bot_token
DISCORD_CLIENT_ID=your_client_id
DISCORD_GUILD_ID=your_test_server_id

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/ruba_trader

# GitHub Integration
GITHUB_TOKEN=your_github_token
GITHUB_USERNAME=4FortuneZW
GITHUB_REPO=RUBA-Trader
GITHUB_BRANCH=main

# Crypto APIs
BINANCE_API_KEY=your_binance_api_key
BINANCE_SECRET_KEY=your_binance_secret_key

# Auto-Sync
GITHUB_AUTO_SYNC=true
GITHUB_SYNC_INTERVAL=30
```

## 📁 Project Structure

```
pxj/
├── src/
│   ├── bot/                  # Discord bot implementation
│   │   ├── handlers/         # Command and event handlers
│   │   └── config.js          # Bot configuration
│   ├── services/              # Business logic
│   │   ├── trading.service.js
│   │   ├── portfolio.service.js
│   │   └── github.service.js  # GitHub automation
│   └── database/              # Database models and migrations
├── scripts/                   # Utility scripts
│   └── auto-git.js           # GitHub automation
├── tests/                     # Test files
├── .github/                   # GitHub Actions workflows
│   └── workflows/
│       └── auto-sync.yml
├── DISCORD_BOT_PLAN.md       # Discord bot planning
├── GITHUB_AUTOMATION_GUIDE.md # GitHub automation guide
└── README.md
```

## 🔄 GitHub Automation

The project includes automatic GitHub synchronization to ensure configuration changes are backed up and remote updates are applied regularly.

### Features
- Auto-push configuration changes
- Auto-pull remote updates
- Conflict detection and resolution
- Discord notifications for sync events

### Setup
See [GITHUB_AUTOMATION_GUIDE.md](GITHUB_AUTOMATION_GUIDE.md) for detailed setup instructions.

## 🛠️ Development

### Running in Development
```bash
npm run dev
```

### Running Tests
```bash
npm test
```

### Database Migrations
```bash
npx prisma migrate dev
```

### Discord Bot Testing
1. Create a Discord server
2. Create a Discord application at https://discord.com/developers/applications
3. Get the bot token and client ID
4. Invite the bot to your server
5. Use `/sync` commands to test GitHub integration

## 📊 Architecture

```
Discord Bot (Node.js)
├── Command Handler
├── Event Listener
├── Alert System
└── GitHub Integration
        ↓
Trading Logic & APIs
        ↓
Database & Cache
        ↓
GitHub Repository
```

For detailed architecture, see [DISCORD_BOT_PLAN.md](DISCORD_BOT_PLAN.md).

## 🔐 Security

- Use environment variables for sensitive data
- Never commit `.env` files
- Use SSH keys or Personal Access Tokens for GitHub
- Implement rate limiting and role-based access control

## 📈 Roadmap

### Phase 1: Foundation ✅
- [x] Project planning and documentation
- [ ] Initialize Discord bot
- [ ] Set up database
- [ ] Implement basic commands

### Phase 2: Core Features
- [ ] Portfolio tracking
- [ ] Trading commands
- [ ] Alert system
- [ ] GitHub automation

### Phase 3: Advanced Features
- [ ] Interactive UI
- [ ] Strategy management
- [ ] Analytics dashboard

### Phase 4: Testing & Deployment
- [ ] Unit and integration tests
- [ ] Docker deployment
- [ ] Production monitoring

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines before submitting PRs.

## 📝 License

TBD

## 📧 Contact

For questions or support, please open an issue on GitHub.

## 🙏 Acknowledgments

- discord.js for the Discord bot framework
- GitHub for repository and CI/CD
- Open-source crypto APIs

---

**Version**: 1.0.0  
**Last Updated**: 2026-01-20  
**Status**: In Development
