require('dotenv').config();
const RUBATraderBot = require('./client');
const AutoGit = require('../../scripts/auto-git');
const config = require('./config');

const bot = new RUBATraderBot();

// Initialize auto-git
const autoGit = new AutoGit();

// Set reload callback
autoGit.setReloadCallback(async () => {
  console.log('🔄 Reloading configuration...');
  
  // Reload bot configuration
  delete require.cache[require.resolve('./config')];
  bot.config = require('./config');
  
  // Reload commands
  await bot.loadCommands();
  await bot.registerCommands();
  
  console.log('✅ Configuration reloaded');
});

// Start auto-sync
if (config.github.autoSync) {
  autoGit.startAutoSync();
}

// Bot event handlers
bot.once('ready', async () => {
  console.log(`✅ Logged in as ${bot.user.tag}`);
  console.log(`📊 Serving ${bot.guilds.cache.size} guild(s)`);

  // Register slash commands
  await bot.registerCommands();

  // Set bot presence
  bot.user.setActivity('crypto markets', { type: 'WATCHING' });

  console.log('🚀 Bot is ready!');
});

bot.on('interactionCreate', async (interaction) => {
  if (!interaction.isChatInputCommand()) return;

  const { commandName } = interaction;

  if (commandName === 'sync') {
    await handleSyncCommand(interaction);
  }
  // Add other command handlers here
});

async function handleSyncCommand(interaction) {
  const subcommand = interaction.options.getSubcommand();

  if (subcommand === 'push') {
    await interaction.reply({ content: '📤 Pushing to GitHub...', fetchReply: true });
    const success = await autoGit.commitAndPush(`Manual sync: ${interaction.user.username}`);
    await interaction.editReply(success ? '✅ Push successful!' : '❌ Push failed!');
  } else if (subcommand === 'pull') {
    await interaction.reply({ content: '📥 Pulling from GitHub...', fetchReply: true });
    const updated = await autoGit.pullAndReload();
    await interaction.editReply(updated ? '✅ Pull successful!' : '✅ Already up to date!');
  }
}

// Error handling
bot.on('error', error => {
  console.error('❌ Discord client error:', error);
});

process.on('unhandledRejection', error => {
  console.error('❌ Unhandled promise rejection:', error);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully...');
  await bot.destroy();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Received SIGINT, shutting down gracefully...');
  await bot.destroy();
  process.exit(0);
});

// Initialize bot
bot.initialize().catch(error => {
  console.error('❌ Failed to initialize bot:', error);
  process.exit(1);
});
