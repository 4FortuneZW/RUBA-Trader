# RUBA Trader Discord Bot - Project Structure

## Directory Structure

```
ruba-trader-discord-bot/
├── .github/                    # GitHub workflows and configurations
│   └── workflows/
│       ├── ci-cd.yml          # CI/CD pipeline
│       └── auto-sync.yml      # Automated sync workflow
├── .vscode/                    # VS Code settings (optional)
│   ├── settings.json
│   ├── extensions.json
│   └── launch.json
├── config/                     # Configuration files
│   ├── bot.config.ts          # Bot settings
│   ├── database.config.ts     # Database settings
│   └── tokens.config.ts       # API tokens management
├── dist/                       # Compiled JavaScript output
├── logs/                       # Application logs
├── node_modules/              # Node dependencies
├── prisma/                     # Database schema and migrations
│   ├── schema.prisma         # Database schema
│   └── migrations/            # Database migrations
├── scripts/                    # Utility scripts
│   ├── auto-sync.sh          # Automated sync script (Unix)
│   ├── auto-sync.ps1         # Automated sync script (PowerShell)
│   ├── deploy-commands.ts    # Deploy Discord commands
│   └── seed-database.ts      # Seed initial data
├── src/                        # Source code
│   ├── commands/              # Discord slash commands
│   │   ├── trading/          # Trading commands
│   │   │   ├── buy.ts
│   │   │   ├── sell.ts
│   │   │   └── swap.ts
│   │   ├── portfolio/        # Portfolio commands
│   │   │   ├── portfolio.ts
│   │   │   └── watchlist.ts
│   │   ├── analytics/        # Analytics commands
│   │   │   ├── market.ts
│   │   │   ├── chart.ts
│   │   │   └── trending.ts
│   │   ├── alerts/           # Alert commands
│   │   │   ├── alert.ts
│   │   │   └── notifications.ts
│   │   └── config/           # Configuration commands
│   │       ├── help.ts
│   │       ├── status.ts
│   │       └── settings.ts
│   ├── events/                # Discord event handlers
│   │   ├── ready.ts          # Bot ready event
│   │   ├── interaction.ts    # Command interactions
│   │   ├── message.ts        # Message events
│   │   ├── guild.ts          # Guild events
│   │   └── error.ts          # Error handling
│   ├── services/              # Business logic services
│   │   ├── trading.service.ts # Trading service
│   │   ├── market.service.ts  # Market data service
│   │   ├── database.service.ts # Database service
│   │   ├── alert.service.ts  # Alert service
│   │   ├── auth.service.ts   # Authentication service
│   │   └── notification.service.ts # Notification service
│   ├── utils/                 # Utility functions
│   │   ├── logger.ts         # Logging utilities
│   │   ├── validators.ts     # Input validation
│   │   ├── helpers.ts        # Helper functions
│   │   ├── errors.ts         # Custom error classes
│   │   └── constants.ts      # Constants and enums
│   ├── models/                # Data models
│   │   ├── user.ts           # User model
│   │   ├── trade.ts          # Trade model
│   │   ├── portfolio.ts      # Portfolio model
│   │   ├── alert.ts          # Alert model
│   │   └── token.ts          # Token model
│   ├── types/                 # TypeScript type definitions
│   │   ├── discord.ts        # Discord types
│   │   ├── trading.ts        # Trading types
│   │   └── api.ts            # API types
│   ├── middlewares/           # Middleware functions
│   │   ├── auth.middleware.ts # Authentication middleware
│   │   ├── rate-limit.middleware.ts # Rate limiting
│   │   └── validation.middleware.ts # Input validation
│   └── index.ts              # Bot entry point
├── tests/                      # Test files
│   ├── unit/                 # Unit tests
│   │   ├── services/         # Service tests
│   │   ├── utils/            # Utility tests
│   │   └── models/           # Model tests
│   ├── integration/          # Integration tests
│   │   ├── commands/         # Command tests
│   │   └── apis/             # API integration tests
│   └── setup.ts              # Test setup
├── .eslintrc.js              # ESLint configuration
├── .gitignore                # Git ignore rules
├── .prettierrc               # Prettier configuration
├── DISCORD_BOT_PLAN.md       # Discord bot planning document
├── PROJECT_STRUCTURE.md      # This file
├── package.json              # Package dependencies and scripts
├── README.md                 # Project README
└── tsconfig.json             # TypeScript configuration
```

## File Descriptions

### Configuration Files

- **`.eslintrc.js`**: ESLint configuration for linting TypeScript code
- **`.prettierrc`**: Prettier configuration for code formatting
- **`tsconfig.json`**: TypeScript compiler configuration
- **`package.json`**: Node.js package configuration with dependencies and scripts

### Discord Commands (`src/commands/`)

Each command file exports a Discord slash command with the following structure:

```typescript
import { SlashCommandBuilder, CommandInteraction } from 'discord.js';

export default {
  data: new SlashCommandBuilder()
    .setName('command-name')
    .setDescription('Command description')
    .addStringOption(option => 
      option.setName('parameter')
        .setDescription('Parameter description')
        .setRequired(true)),
  
  async execute(interaction: CommandInteraction) {
    // Command logic here
  }
};
```

### Services (`src/services/`)

Services contain business logic and interact with external APIs and database:

- **Trading Service**: Handles buy, sell, and swap operations
- **Market Service**: Fetches market data from crypto APIs
- **Database Service**: Manages database operations
- **Alert Service**: Manages price alerts
- **Auth Service**: Handles authentication and authorization
- **Notification Service**: Manages notifications and alerts

### Events (`src/events/`)

Event handlers for Discord events:

```typescript
import { Client } from 'discord.js';

export default (client: Client) => {
  client.on('eventName', async (...args) => {
    // Event handling logic
  });
};
```

### Models (`src/models/`)

Data models representing database entities:

- **User**: Discord user information and settings
- **Trade**: Trade history and details
- **Portfolio**: User's portfolio holdings
- **Alert**: Price alerts configuration
- **Token**: Cryptocurrency token information

### Utils (`src/utils/`)

Utility functions:

- **logger**: Winston logger configuration
- **validators**: Input validation functions
- **helpers**: Helper functions for common operations
- **errors**: Custom error classes
- **constants**: Constants and enums used throughout the application

### Scripts (`scripts/`)

Utility scripts for development and deployment:

- **`auto-sync.sh`**: Automated Git sync script for Unix/Linux/macOS
- **`auto-sync.ps1`**: Automated Git sync script for Windows PowerShell
- **`deploy-commands.ts`**: Deploy Discord slash commands
- **`seed-database.ts`**: Seed database with initial data

### Tests (`tests/`)

Test files organized by type:

- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test interactions between components
- **Test Setup**: Configuration for test environment

## Development Workflow

### 1. Setup

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your configuration
# Set up database
npx prisma migrate dev

# Deploy Discord commands
npm run deploy-commands
```

### 2. Development

```bash
# Start development server with hot reload
npm run dev

# Watch for changes and rebuild
npm run watch

# Run linter
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format
```

### 3. Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage

# Type check
npm run type-check
```

### 4. Building

```bash
# Build TypeScript to JavaScript
npm run build

# Start production server
npm start
```

### 5. Git Sync

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

## Configuration

### Environment Variables

See `.env.example` for all available configuration options.

### Discord Bot Setup

1. Create a Discord application at https://discord.com/developers/applications
2. Create a bot user and get the token
3. Enable necessary bot permissions
4. Invite the bot to your server using the OAuth2 URL generator

### Database Setup

1. Install PostgreSQL
2. Create a database for the bot
3. Update `DATABASE_URL` in `.env`
4. Run migrations: `npx prisma migrate dev`

### API Setup

1. Get API keys from crypto data providers (CoinGecko, Binance, etc.)
2. Update API keys in `.env`
3. Configure rate limits and quotas

## Dependencies

### Core Dependencies

- `discord.js`: Discord API wrapper
- `dotenv`: Environment variable management
- `axios`: HTTP client for API calls
- `winston`: Logging framework
- `prisma`: Database ORM
- `ioredis`: Redis client for caching
- `decimal.js`: Precise decimal arithmetic
- `moment`: Date/time manipulation

### Development Dependencies

- `typescript`: TypeScript compiler
- `ts-node`: TypeScript execution
- `eslint`: Code linting
- `prettier`: Code formatting
- `jest`: Testing framework
- `ts-jest`: TypeScript Jest transformer
- `husky`: Git hooks
- `lint-staged`: Lint staged files

## Deployment

### CI/CD Pipeline

The project includes GitHub Actions workflows for:

1. **CI/CD Pipeline** (`.github/workflows/ci-cd.yml`):
   - Runs tests on push and pull requests
   - Performs security audits
   - Builds the project
   - Deploys to production on main branch

2. **Automated Sync** (`.github/workflows/auto-sync.yml`):
   - Syncs with remote every 6 hours
   - Can be triggered manually
   - Generates sync reports

### Deployment Platforms

Recommended platforms:

- **Railway**: Easy deployment with automatic builds
- **Render**: Free tier available, good for small projects
- **Heroku**: Reliable, paid plans required
- **VPS**: Full control, requires manual setup

### Deployment Steps

1. Set up hosting platform account
2. Connect GitHub repository
3. Configure environment variables
4. Deploy and verify
5. Set up monitoring and logging

## Best Practices

### Code Organization

- Keep commands focused and single-purpose
- Separate business logic from Discord interactions
- Use services for reusable logic
- Organize types in dedicated files

### Error Handling

- Use try-catch blocks for async operations
- Implement proper error logging
- Provide user-friendly error messages
- Handle edge cases gracefully

### Performance

- Cache frequently accessed data
- Use pagination for large datasets
- Implement rate limiting
- Optimize database queries

### Security

- Never commit sensitive data
- Use environment variables for secrets
- Implement proper authentication
- Validate all user inputs
- Use prepared statements for database queries

### Testing

- Write unit tests for critical functions
- Test edge cases and error conditions
- Use mocks for external dependencies
- Maintain test coverage above 80%

## Troubleshooting

### Common Issues

1. **Bot not responding**: Check bot token and permissions
2. **Commands not appearing**: Re-deploy commands
3. **Database connection issues**: Verify DATABASE_URL
4. **API rate limits**: Check API keys and quotas
5. **Memory issues**: Implement caching and pagination

### Debug Mode

Enable debug logging:

```bash
# In .env
LOG_LEVEL=debug

# Run in verbose mode
npm run dev
```

## Support

For issues and questions:

- GitHub Issues: https://github.com/4FortuneZW/RUBA-Trader/issues
- Discord Community: [Link to Discord server]
- Documentation: [Link to documentation]

---

**Last Updated:** 2026-01-20  
**Version:** 1.0.0
