# RUBA Trader Discord Bot - Setup Guide

## Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js**: Version 18.0.0 or higher
- **npm**: Version 9.0.0 or higher
- **Git**: For version control
- **PostgreSQL**: Database (optional, can use cloud services)

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/4FortuneZW/RUBA-Trader.git
cd RUBA-Trader
```

2. **Install dependencies**

```bash
npm install
```

3. **Set up environment variables**

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your configuration
# You'll need to add your Discord bot token and other API keys
```

4. **Set up the database**

```bash
# Run database migrations
npx prisma migrate dev

# (Optional) Seed database with initial data
npx prisma db seed
```

5. **Deploy Discord commands**

```bash
npm run deploy-commands
```

6. **Start the bot**

```bash
# Development mode
npm run dev

# Production mode
npm run build
npm start
```

## Discord Bot Setup

### 1. Create Discord Application

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click "New Application"
3. Give your application a name (e.g., "RUBA Trader")
4. Click "Create"

### 2. Create Bot User

1. In your application, go to the "Bot" tab
2. Click "Add Bot"
3. Click "Yes, do it!"
4. Copy the "Token" (you'll need this for `.env`)

### 3. Configure Bot Permissions

In the "Bot" tab, enable:

- **Message Content Intent**: Required for reading messages
- **Server Members Intent**: Required for user lookups
- **Presence Intent**: Optional, for presence features

### 4. Invite Bot to Server

1. Go to "OAuth2" > "URL Generator"
2. Select scopes:
   - `bot`
   - `applications.commands`
3. Select bot permissions:
   - Send Messages
   - Read Message History
   - Use Slash Commands
   - Embed Links
   - Attach Files
4. Copy the generated URL and open it in your browser
5. Select your server and authorize the bot

## Environment Configuration

### Required Environment Variables

```env
# Discord Bot Configuration
DISCORD_BOT_TOKEN=your_discord_bot_token_here
DISCORD_BOT_CLIENT_ID=your_discord_bot_client_id_here
DISCORD_GUILD_ID=your_discord_guild_id_here

# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/ruba_trader

# Redis Configuration (for caching)
REDIS_URL=redis://localhost:6379

# Environment
NODE_ENV=development
```

### Optional Environment Variables

```env
# Crypto API Configuration
COINGECKO_API_KEY=your_coingecko_api_key_here
BINANCE_API_KEY=your_binance_api_key_here
BINANCE_API_SECRET=your_binance_api_secret_here

# Exchange API Configuration (for trading)
EXCHANGE_API_KEY=your_exchange_api_key_here
EXCHANGE_API_SECRET=your_exchange_api_secret_here

# Logging
LOG_LEVEL=info
LOG_FILE=logs/bot.log

# Rate Limiting
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX_REQUESTS=100

# Security
ENCRYPTION_KEY=your_encryption_key_here
JWT_SECRET=your_jwt_secret_here

# Trading Configuration
MAX_TRADE_AMOUNT=1000
DEFAULT_CURRENCY=USD
RISK_LEVEL=MEDIUM
```

## API Setup

### CoinGecko API

1. Register at [CoinGecko](https://www.coingecko.com/en/api/pricing)
2. Get your API key
3. Add to `.env`:
   ```
   COINGECKO_API_KEY=your_api_key_here
   ```

### Binance API

1. Register at [Binance](https://www.binance.com/en/register)
2. Enable 2FA
3. Create API keys in API Management
4. Add to `.env`:
   ```
   BINANCE_API_KEY=your_api_key_here
   BINANCE_API_SECRET=your_api_secret_here
   ```

### Exchange API

For trading functionality, you'll need exchange API keys:

1. Register on your preferred exchange (Binance, Coinbase, etc.)
2. Create API keys with trading permissions
3. Add to `.env`:
   ```
   EXCHANGE_API_KEY=your_exchange_api_key_here
   EXCHANGE_API_SECRET=your_exchange_api_secret_here
   ```

## Database Setup

### Using PostgreSQL

1. Install PostgreSQL:
   - **Windows**: Download from [postgresql.org](https://www.postgresql.org/download/windows/)
   - **macOS**: `brew install postgresql`
   - **Linux**: `sudo apt-get install postgresql postgresql-contrib`

2. Create database:
   ```bash
   createdb ruba_trader
   ```

3. Update `.env`:
   ```
   DATABASE_URL=postgresql://postgres:your_password@localhost:5432/ruba_trader
   ```

4. Run migrations:
   ```bash
   npx prisma migrate dev
   ```

### Using Cloud Database Services

#### Neon (PostgreSQL)

1. Sign up at [Neon](https://neon.tech/)
2. Create a new project
3. Copy the connection string
4. Add to `.env`:
   ```
   DATABASE_URL=postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb
   ```

#### Supabase (PostgreSQL)

1. Sign up at [Supabase](https://supabase.com/)
2. Create a new project
3. Get database URL from settings
4. Add to `.env` as `DATABASE_URL`

### Using MongoDB

1. Install MongoDB:
   - **Windows**: Download from [mongodb.com](https://www.mongodb.com/try/download/community)
   - **macOS**: `brew install mongodb-community`
   - **Linux**: `sudo apt-get install mongodb`

2. Start MongoDB:
   ```bash
   # macOS
   brew services start mongodb-community
   
   # Linux
   sudo systemctl start mongod
   ```

3. Update `.env`:
   ```
   DATABASE_URL=mongodb://localhost:27017/ruba_trader
   ```

## Redis Setup (Optional)

Redis is used for caching and rate limiting.

### Local Redis

1. Install Redis:
   - **Windows**: Use WSL or Docker
   - **macOS**: `brew install redis`
   - **Linux**: `sudo apt-get install redis-server`

2. Start Redis:
   ```bash
   # macOS
   brew services start redis
   
   # Linux
   sudo systemctl start redis
   ```

3. Update `.env`:
   ```
   REDIS_URL=redis://localhost:6379
   ```

### Redis Cloud

1. Sign up at [Redis Cloud](https://redis.com/try-free/)
2. Create a new database
3. Copy the connection URL
4. Add to `.env` as `REDIS_URL`

## Development Workflow

### Running the Bot

```bash
# Development mode with hot reload
npm run dev

# Production mode
npm run build
npm start
```

### Code Quality

```bash
# Run linter
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Type checking
npm run type-check
```

### Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Git Workflow

```bash
# Sync with remote (Unix/Linux/macOS)
npm run sync

# Sync with remote (Windows PowerShell)
.\scripts\auto-sync.ps1

# Sync with verbose output
npm run sync:verbose

# Force sync (may discard local changes)
npm run sync:force

# Dry run (no changes made)
npm run sync:dry-run
```

## Automated GitHub Workflow

The project includes automated GitHub workflows for continuous integration and deployment.

### CI/CD Pipeline

The CI/CD pipeline runs automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch

It performs:
- Code linting
- Type checking
- Running tests
- Building the project
- Security audits

### Automated Sync

The automated sync workflow:
- Runs every 6 hours
- Can be triggered manually from GitHub Actions
- Syncs local changes with remote
- Generates sync reports

To trigger manually:
1. Go to GitHub repository
2. Navigate to "Actions" tab
3. Select "Automated Sync"
4. Click "Run workflow"

## Deployment

### Deploy to Railway

1. Install Railway CLI:
   ```bash
   npm install -g @railway/cli
   railway login
   ```

2. Initialize Railway:
   ```bash
   railway init
   railway up
   ```

3. Add environment variables in Railway dashboard

4. Deploy:
   ```bash
   railway up
   ```

### Deploy to Render

1. Create account at [Render](https://render.com/)
2. Create new "Web Service"
3. Connect GitHub repository
4. Configure build and start commands
5. Add environment variables
6. Deploy

### Deploy to Heroku

1. Install Heroku CLI:
   ```bash
   npm install -g heroku
   heroku login
   ```

2. Create app:
   ```bash
   heroku create ruba-trader-bot
   ```

3. Set environment variables:
   ```bash
   heroku config:set DISCORD_BOT_TOKEN=your_token
   heroku config:set DATABASE_URL=your_database_url
   ```

4. Deploy:
   ```bash
   git push heroku main
   ```

## Troubleshooting

### Bot Not Responding

1. Check bot token in `.env`
2. Verify bot permissions in Discord
3. Check logs:
   ```bash
   tail -f logs/bot.log
   ```
4. Ensure bot is invited to server

### Commands Not Appearing

1. Re-deploy commands:
   ```bash
   npm run deploy-commands
   ```
2. Wait up to 1 hour for global commands
3. For instant testing, deploy to guild:
   ```
   Set DISCORD_GUILD_ID in .env
   ```

### Database Connection Issues

1. Verify `DATABASE_URL` in `.env`
2. Check database is running
3. Ensure database credentials are correct
4. Check firewall settings

### API Rate Limits

1. Check API keys are valid
2. Implement caching (Redis)
3. Use paid API tiers for higher limits
4. Add rate limiting in code

## Support

For help and support:

- **GitHub Issues**: https://github.com/4FortuneZW/RUBA-Trader/issues
- **Documentation**: See `DISCORD_BOT_PLAN.md` and `PROJECT_STRUCTURE.md`
- **Discord Community**: [Link to Discord server]

## Next Steps

1. Complete setup following this guide
2. Read `DISCORD_BOT_PLAN.md` for detailed architecture
3. Explore `PROJECT_STRUCTURE.md` for code organization
4. Start with basic commands in `/ping` and `/help`
5. Gradually add trading features

---

**Last Updated**: 2026-01-20  
**Version**: 1.0.0
