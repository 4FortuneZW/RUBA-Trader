import { REST, Routes } from 'discord.js';
import dotenv from 'dotenv';

dotenv.config();

const commands = [
  {
    name: 'ping',
    description: 'Replies with Pong!',
  },
  {
    name: 'balance',
    description: 'Show your current balance',
  },
  {
    name: 'portfolio',
    description: 'Show your portfolio overview',
  },
  {
    name: 'price',
    description: 'Get current price of a cryptocurrency',
    options: [
      {
        name: 'token',
        type: 3, // STRING
        description: 'The cryptocurrency symbol (e.g., BTC, ETH)',
        required: true,
      },
    ],
  },
  {
    name: 'help',
    description: 'Show help menu',
  },
];

const rest = new REST({ version: '10' }).setToken(process.env.DISCORD_BOT_TOKEN!);

(async () => {
  try {
    console.log('Started refreshing application (/) commands.');

    const guildId = process.env.DISCORD_GUILD_ID;

    if (guildId) {
      // Deploy to a specific guild for testing
      await rest.put(Routes.applicationGuildCommands(process.env.DISCORD_BOT_CLIENT_ID!, guildId), {
        body: commands,
      });
      console.log('Successfully reloaded guild application (/) commands.');
    } else {
      // Deploy globally
      await rest.put(Routes.applicationCommands(process.env.DISCORD_BOT_CLIENT_ID!), {
        body: commands,
      });
      console.log('Successfully reloaded global application (/) commands.');
    }
  } catch (error) {
    console.error(error);
  }
})();
