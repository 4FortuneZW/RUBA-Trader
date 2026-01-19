const { Client, GatewayIntentBits, Collection } = require('discord.js');
const fs = require('fs');
const path = require('path');
const config = require('./config');

class RUBATraderBot extends Client {
  constructor() {
    super({
      intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
      ],
    });

    this.config = config;
    this.commands = new Collection();
    this.cooldowns = new Collection();
    this.startedAt = null;
  }

  async initialize() {
    console.log('🤖 Initializing RUBA Trader Discord Bot...');

    // Load commands
    await this.loadCommands();

    // Load events
    await this.loadEvents();

    // Login to Discord
    await this.login(this.config.discord.token);

    this.startedAt = new Date();
    console.log('✅ Bot initialized successfully!');
  }

  async loadCommands() {
    console.log('📂 Loading commands...');

    const commandsPath = path.join(__dirname, '..', 'handlers', 'commands');

    if (!fs.existsSync(commandsPath)) {
      fs.mkdirSync(commandsPath, { recursive: true });
      return;
    }

    const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));

    for (const file of commandFiles) {
      const filePath = path.join(commandsPath, file);
      const command = require(filePath);

      if ('data' in command && 'execute' in command) {
        this.commands.set(command.data.name, command);
        console.log(`✅ Loaded command: ${command.data.name}`);
      } else {
        console.log(`⚠️  Skipping ${file}: missing required "data" or "execute" property`);
      }
    }

    console.log(`📊 Loaded ${this.commands.size} commands`);
  }

  async loadEvents() {
    console.log('📂 Loading events...');

    const eventsPath = path.join(__dirname, '..', 'handlers', 'events');

    if (!fs.existsSync(eventsPath)) {
      fs.mkdirSync(eventsPath, { recursive: true });
      return;
    }

    const eventFiles = fs.readdirSync(eventsPath).filter(file => file.endsWith('.js'));

    for (const file of eventFiles) {
      const filePath = path.join(eventsPath, file);
      const event = require(filePath);

      if (event.once) {
        this.once(event.name, (...args) => event.execute(...args));
      } else {
        this.on(event.name, (...args) => event.execute(...args));
      }

      console.log(`✅ Loaded event: ${event.name}`);
    }
  }

  async registerCommands() {
    console.log('📝 Registering slash commands...');

    const commands = [];

    for (const command of this.commands.values()) {
      commands.push(command.data.toJSON());
    }

    if (this.config.development.nodeEnv === 'development' && this.config.discord.guildId) {
      // Register commands to specific guild (faster for development)
      const guild = await this.guilds.fetch(this.config.discord.guildId);
      await guild.commands.set(commands);
      console.log(`✅ Registered ${commands.length} commands to guild: ${guild.name}`);
    } else {
      // Register commands globally (takes up to 1 hour to propagate)
      await this.application.commands.set(commands);
      console.log(`✅ Registered ${commands.length} commands globally`);
    }
  }

  getUptime() {
    if (!this.startedAt) return '0s';
    const uptime = Date.now() - this.startedAt.getTime();
    const seconds = Math.floor(uptime / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) return `${days}d ${hours % 24}h ${minutes % 60}m`;
    if (hours > 0) return `${hours}h ${minutes % 60}m`;
    if (minutes > 0) return `${minutes}m ${seconds % 60}s`;
    return `${seconds}s`;
  }

  isAdmin(userId) {
    return this.config.admin.userIds.includes(userId);
  }
}

module.exports = RUBATraderBot;
