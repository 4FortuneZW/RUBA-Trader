require('dotenv').config();

module.exports = {
  // Discord Configuration
  discord: {
    token: process.env.DISCORD_TOKEN,
    clientId: process.env.DISCORD_CLIENT_ID,
    guildId: process.env.DISCORD_GUILD_ID,
  },

  // Database Configuration
  database: {
    url: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/ruba_trader?schema=public',
  },

  // GitHub Configuration
  github: {
    token: process.env.GITHUB_TOKEN,
    username: process.env.GITHUB_USERNAME,
    repo: process.env.GITHUB_REPO,
    branch: process.env.GITHUB_BRANCH || 'main',
    autoSync: process.env.GITHUB_AUTO_SYNC === 'true',
    syncInterval: parseInt(process.env.GITHUB_SYNC_INTERVAL) || 30, // minutes
    pushOnConfigChange: process.env.GITHUB_PUSH_ON_CONFIG_CHANGE === 'true',
  },

  // Binance API Configuration
  binance: {
    apiKey: process.env.BINANCE_API_KEY,
    secretKey: process.env.BINANCE_SECRET_KEY,
    testnet: process.env.BINANCE_TESTNET === 'true',
  },

  // Redis Configuration
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT) || 6379,
    password: process.env.REDIS_PASSWORD,
    db: parseInt(process.env.REDIS_DB) || 0,
  },

  // Logging Configuration
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    file: process.env.LOG_FILE || 'logs/bot.log',
  },

  // Bot Configuration
  bot: {
    prefix: process.env.BOT_PREFIX || '/',
    commandCooldown: parseInt(process.env.COMMAND_COOLDOWN) || 5000,
    maxRetries: parseInt(process.env.MAX_RETRIES) || 3,
  },

  // Trading Configuration
  trading: {
    enabled: process.env.TRADING_ENABLED === 'true',
    defaultSymbol: process.env.DEFAULT_TRADING_SYMBOL || 'BTCUSDT',
    defaultOrderType: process.env.DEFAULT_ORDER_TYPE || 'LIMIT',
  },

  // Alert Configuration
  alerts: {
    enabled: process.env.ALERT_ENABLED === 'true',
    channelId: process.env.ALERT_CHANNEL_ID,
  },

  // Admin Configuration
  admin: {
    userIds: process.env.ADMIN_USER_IDS ? process.env.ADMIN_USER_IDS.split(',') : [],
  },

  // Notification Configuration
  notifications: {
    channelId: process.env.NOTIFICATION_CHANNEL_ID,
    onTrade: process.env.NOTIFICATION_ON_TRADE === 'true',
    onAlert: process.env.NOTIFICATION_ON_ALERT === 'true',
    onError: process.env.NOTIFICATION_ON_ERROR === 'true',
  },

  // Risk Management
  riskManagement: {
    maxTradeAmount: parseFloat(process.env.MAX_TRADE_AMOUNT) || 1000,
    dailyLossLimit: parseFloat(process.env.DAILY_LOSS_LIMIT) || 500,
    positionSizePercentage: parseFloat(process.env.POSITION_SIZE_PERCENTAGE) || 5,
  },

  // Development Settings
  development: {
    nodeEnv: process.env.NODE_ENV || 'development',
    debug: process.env.DEBUG === 'true',
  },
};
