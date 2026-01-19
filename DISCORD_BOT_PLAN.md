# Discord Bot Planning Document
## RUBA Trader - Crypto Trading Bot with Discord Integration

---

## 📋 Executive Summary

This document outlines the comprehensive plan for building a Discord bot that integrates with the RUBA Trader cryptocurrency trading bot. The Discord bot will serve as an interface for monitoring, controlling, and receiving alerts from the trading system.

---

## 🎯 Project Goals

1. **Real-time Monitoring**: Provide live updates on trading activities, portfolio status, and market conditions
2. **User Control**: Allow users to execute commands to manage trading strategies
3. **Alert System**: Send notifications for important events (trade executions, price alerts, risk warnings)
4. **Community Features**: Enable sharing of trading insights and strategies (optional)
5. **GitHub Integration**: Automatic synchronization with GitHub repository

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Discord Bot (Node.js)                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Command     │  │ Event       │  │ Alert       │        │
│  │ Handler     │  │ Listener    │  │ System      │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Trading     │  │ Portfolio   │  │ Risk        │        │
│  │ Manager     │  │ Tracker     │  │ Manager     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                    Data Layer                                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Database    │  │ API         │  │ Cache       │        │
│  │ (PostgreSQL)│  │ (Crypto)    │  │ (Redis)     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                          │
│              (Automatic Push/Pull Integration)                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

### Core Technologies
- **Runtime**: Node.js 18+ or 20+
- **Discord Library**: discord.js v14
- **Database**: PostgreSQL (with Prisma ORM)
- **Caching**: Redis (for real-time data)
- **API Integration**: Crypto APIs (Binance, Coinbase, etc.)

### GitHub Integration
- **GitHub Actions**: CI/CD for automation
- **Git Hooks**: Pre-commit and post-commit hooks
- **GitHub CLI**: For automatic push/pull operations

### DevOps & Deployment
- **Container**: Docker
- **Orchestration**: Docker Compose (local) / Kubernetes (production)
- **Monitoring**: PM2 / systemd
- **Secrets Management**: Environment variables

---

## 📊 Discord Bot Features

### 1. **Command System**

#### Portfolio Commands
- `/portfolio` - Display current portfolio value and holdings
- `/balance` - Show account balance (USD and crypto)
- `/history [days]` - Show transaction history for specified period
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

#### Admin Commands
- `/config [key] [value]` - Update bot configuration
- `/sync` - Manually trigger GitHub sync
- `/backup` - Create database backup
- `/logs [level]` - View system logs

### 2. **Event Notifications**

Real-time notifications for:
- ✅ Trade execution confirmation
- 📊 Price alerts triggered
- ⚠️ Risk warnings (e.g., portfolio drops >10%)
- 📈 Strategy activation/deactivation
- 🔄 Daily/weekly portfolio reports
- 💰 Significant profit/loss events

### 3. **Interactive Features**

- **Embed Messages**: Rich formatting for portfolio data, charts, and tables
- **Buttons**: Quick actions (Buy/Sell buttons, strategy toggles)
- **Dropdowns**: Select trading pairs, timeframes
- **Modals**: Complex input forms (advanced trading parameters)
- **Slash Commands Autocomplete**: Intelligent suggestions

---

## 🤝 GitHub Integration Plan

### 1. **Automatic Push Strategy**

#### Triggers for Automatic Push
- Configuration changes (`/config` command)
- Strategy updates (new/modified trading strategies)
- System state changes (bot restart, crash recovery)
- Scheduled daily/weekly backups

#### Implementation Approach

**Option A: Git Hooks (Recommended for Development)**
```bash
# .git/hooks/post-commit
#!/bin/bash
git push origin HEAD
```

**Option B: GitHub Actions CI/CD (Recommended for Production)**
```yaml
name: Auto Sync
on:
  push:
    branches: [main, develop]
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
```

**Option C: In-Bot Automation**
```javascript
// Integrated within the bot
async function autoCommitAndPush(message) {
  const git = simpleGit();
  await git.add('.');
  await git.commit(message);
  await git.push('origin', 'main');
}
```

### 2. **Automatic Pull Strategy**

#### Triggers for Automatic Pull
- Remote repository updates detected
- Scheduled sync intervals (e.g., every hour)
- Admin command `/sync pull`
- Bot restart (pull latest configuration)

#### Implementation
```javascript
// Scheduled pull
cron.schedule('0 * * * *', async () => {
  const git = simpleGit();
  await git.pull('origin', 'main');
  // Reload configuration if needed
  await reloadConfiguration();
});
```

### 3. **Conflict Resolution Strategy**

- **Automatic**: Prefer local changes for config files, remote for code
- **Manual**: Notify admin via Discord if conflicts detected
- **Backup**: Create timestamped backup before pull
- **Rollback**: Ability to revert to previous state

---

## 🗂️ Project Structure

```
pxj/
├── src/
│   ├── bot/
│   │   ├── index.js              # Bot entry point
│   │   ├── client.js              # Discord client setup
│   │   ├── config.js              # Bot configuration
│   │   └── handlers/
│   │       ├── commands/
│   │       │   ├── portfolio.js
│   │       │   ├── trading.js
│   │       │   ├── alerts.js
│   │       │   └── admin.js
│   │       ├── events/
│   │       │   ├── ready.js
│   │       │   ├── messageCreate.js
│   │       │   └── interactionCreate.js
│   │       └── buttons.js
│   ├── services/
│   │   ├── trading.service.js    # Trading logic
│   │   ├── portfolio.service.js   # Portfolio management
│   │   ├── alert.service.js       # Alert system
│   │   └── github.service.js      # GitHub integration
│   ├── database/
│   │   ├── models/
│   │   │   ├── user.model.js
│   │   │   ├── trade.model.js
│   │   │   └── alert.model.js
│   │   └── migrations/
│   ├── utils/
│   │   ├── logger.js
│   │   ├── validators.js
│   │   └── helpers.js
│   └── middleware/
│       ├── auth.js
│       └── rateLimiter.js
├── prisma/
│   └── schema.prisma              # Database schema
├── tests/
│   ├── unit/
│   └── integration/
├── .github/
│   └── workflows/
│       └── auto-sync.yml          # GitHub Actions workflow
├── .env.example                   # Environment template
├── .git/
│   └── hooks/
│       ├── pre-commit             # Pre-commit hook
│       └── post-commit            # Post-commit push hook
├── docker-compose.yml             # Docker setup
├── Dockerfile
├── package.json
├── README.md
└── DISCORD_BOT_PLAN.md            # This file
```

---

## 📝 Development Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Set up project structure
- [ ] Initialize Discord bot with discord.js
- [ ] Implement basic commands (`/help`, `/ping`)
- [ ] Set up database with Prisma
- [ ] Create GitHub Actions workflow
- [ ] Configure git hooks for auto-push

### Phase 2: Core Features (Week 3-4)
- [ ] Implement portfolio tracking
- [ ] Connect to crypto APIs
- [ ] Build trading commands
- [ ] Create alert system
- [ ] Add GitHub auto-pull functionality
- [ ] Implement error handling

### Phase 3: Advanced Features (Week 5-6)
- [ ] Add interactive UI (buttons, modals)
- [ ] Implement strategy management
- [ ] Build notification system
- [ ] Add admin commands
- [ ] Create analytics dashboard
- [ ] Performance optimization

### Phase 4: Testing & Deployment (Week 7-8)
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Load testing
- [ ] Set up Docker deployment
- [ ] Configure monitoring
- [ ] Production deployment
- [ ] Documentation

---

## 🔐 Security Considerations

1. **Token Security**
   - Store Discord bot token in environment variables
   - Use GitHub Secrets for CI/CD
   - Rotate tokens periodically

2. **Command Authorization**
   - Role-based access control (RBAC)
   - Whitelist allowed Discord servers/users
   - Rate limiting to prevent abuse

3. **API Security**
   - Secure crypto API keys
   - Implement request signing
   - Use encrypted database connections

4. **GitHub Security**
   - Use SSH keys for git operations
   - Enable two-factor authentication
   - Use protected branches

---

## 📊 Monitoring & Logging

1. **Application Metrics**
   - Command execution count
   - Response times
   - Error rates
   - User engagement

2. **Logging Strategy**
   - Structured logging with winston/pino
   - Log levels: error, warn, info, debug
   - Centralized log storage
   - Alert on critical errors

3. **Health Checks**
   - Bot status (online/offline)
   - Database connection
   - API connectivity
   - GitHub sync status

---

## 🔄 GitHub Automation Scripts

### Auto-Push Script (Node.js)
```javascript
const { SimpleGit } = require('simple-git');

class GitHubAutoPush {
  constructor() {
    this.git = new SimpleGit();
  }

  async commitAndPush(message) {
    try {
      await this.git.add('.');
      await this.git.commit(message);
      await this.git.push('origin', 'HEAD');
      console.log('✅ Auto-push successful');
    } catch (error) {
      console.error('❌ Auto-push failed:', error.message);
    }
  }

  async checkForUpdates() {
    try {
      await this.git.fetch();
      const status = await this.git.status();
      if (status.behind > 0) {
        console.log('📥 New changes available');
        return true;
      }
      return false;
    } catch (error) {
      console.error('❌ Check failed:', error.message);
      return false;
    }
  }

  async pullAndRestart() {
    try {
      await this.git.pull('origin', 'HEAD');
      console.log('✅ Pull successful - restarting...');
      process.exit(0); // Let PM2/Systemd restart
    } catch (error) {
      console.error('❌ Pull failed:', error.message);
    }
  }
}
```

### GitHub Actions Workflow
```yaml
name: Discord Bot Auto Sync

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check for configuration changes
        id: check-config
        run: |
          if git diff HEAD^ HEAD --name-only | grep -E '\.(js|json|env)'; then
            echo "changes=true" >> $GITHUB_OUTPUT
          fi

      - name: Deploy if config changed
        if: steps.check-config.outputs.changes == 'true'
        run: |
          echo "Configuration changed - deploying..."
          # Add deployment commands here
```

---

## 📈 Success Metrics

1. **User Engagement**
   - Daily active users
   - Commands executed per day
   - User retention rate

2. **System Performance**
   - Bot uptime (>99%)
   - Average response time (<500ms)
   - Error rate (<0.1%)

3. **Trading Performance**
   - Portfolio growth rate
   - Successful trade rate
   - Alert accuracy

---

## 🚀 Next Steps

1. ✅ Review and approve this plan
2. 📦 Initialize Node.js project with dependencies
3. 🔑 Set up Discord application and get bot token
4. 🗄️ Set up database (PostgreSQL)
5. 🐳 Configure Docker for local development
6. 🔐 Set up environment variables
7. 📝 Start Phase 1 implementation

---

## 📚 References

- [discord.js Documentation](https://discord.js.org/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Crypto APIs](https://docs.binance.us/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Document Version**: 1.0  
**Last Updated**: 2026-01-20  
**Status**: Draft for Review  
