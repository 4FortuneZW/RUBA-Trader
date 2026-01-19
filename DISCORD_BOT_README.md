# Discord Bot Integration - Quick Start Guide

## Overview

This guide will help you set up the Discord bot integration for RUBA Trader using the Model Context Protocol (MCP). This integration allows AI assistants like Claude to interact with your Discord channels.

## Prerequisites

- Python 3.8+ (3.13+ requires additional audioop-lts package)
- Discord account
- Git installed
- UV package manager (auto-installed by setup script)

## Quick Setup (5 Minutes)

### Step 1: Create Discord Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click "New Application"
3. Name your application (e.g., "RUBA Trader Bot")
4. Go to the "Bot" tab
5. Click "Add Bot"
6. Copy your **Bot Token** (you'll need this later)

### Step 2: Enable Bot Intents

In the Bot tab, scroll down to "Privileged Gateway Intents" and enable:
- ✅ MESSAGE CONTENT INTENT
- ✅ PRESENCE INTENT
- ✅ SERVER MEMBERS INTENT

Click "Save Changes".

### Step 3: Invite Bot to Your Server

1. Go to the "OAuth2" → "URL Generator" tab
2. Under "Scopes", select:
   - ✅ bot
3. Under "Bot Permissions", select:
   - ✅ Send Messages
   - ✅ Read Messages/View Channels
   - ✅ Embed Links
   - ✅ Attach Files
   - ✅ Add Reactions
   - ✅ Use Slash Commands
4. Copy the generated URL and open it in your browser
5. Select your server and authorize the bot

### Step 4: Run Setup Script

**On Windows (PowerShell):**
```powershell
# Install Git for Windows if not already installed
# Download from: https://git-scm.com/download/win

# Open PowerShell in project directory
cd C:\Users\Fortune\.cursor\worktrees\crypto_journal\fot

# Run setup (you may need to use bash if script has issues)
# or manually follow the Manual Setup below
```

**On macOS/Linux:**
```bash
# Make script executable
chmod +x discord-bot-setup.sh

# Run setup
./discord-bot-setup.sh
```

### Step 5: Configure Environment Variables

After running the setup script:

1. Open `.env` file in your project root
2. Update the Discord token:
```env
DISCORD_TOKEN=your_actual_discord_bot_token_here
```

### Step 6: Test Bot Connection

```bash
# Run initialization script
python discord-bot/init_bot.py

# Run test script
python discord-bot/test_bot.py
```

You should see:
```
✓ Bot connected successfully!
  Bot name: RUBA Trader Bot
  Bot ID: 123456789012345678
  Connected to 1 servers

  Servers:
    - Your Server Name (ID: 987654321098765432)
```

### Step 7: Configure Claude Desktop

1. Copy your Discord bot token
2. Locate your Claude Desktop config file:
   - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Linux**: `~/.config/Claude/claude_desktop_config.json`
3. Add or update the following configuration:

```json
{
  "mcpServers": {
    "discord": {
      "command": "uv",
      "args": [
        "--directory",
        "C:\\Users\\Fortune\\.cursor\\worktrees\\crypto_journal\\fot\\discord-bot\\mcp-discord",
        "run",
        "mcp-discord"
      ],
      "env": {
        "DISCORD_TOKEN": "your_actual_discord_bot_token_here"
      }
    }
  }
}
```

**Note**: Update the path to match your actual project directory.

4. Restart Claude Desktop

### Step 8: Verify Integration in Claude Desktop

1. Open Claude Desktop
2. Start a new conversation
3. Ask Claude to list Discord servers or channels
4. Example prompt: "What Discord servers can you access?"

## Manual Setup (Alternative)

If the setup script doesn't work for you, follow these steps manually:

### 1. Clone MCP Discord Repository

```bash
# Create discord-bot directory
mkdir discord-bot
cd discord-bot

# Clone the repository
git clone https://github.com/hanweg/mcp-discord.git
cd mcp-discord
```

### 2. Install Dependencies

```bash
# Create virtual environment
uv venv

# Activate virtual environment
# On Windows:
.venv\Scripts\activate
# On macOS/Linux:
source .venv/bin/activate

# Install package
uv pip install -e .

# For Python 3.13+, install audioop-lts
uv pip install audioop-lts
```

### 3. Configure Environment

Create `.env` file in project root:
```env
DISCORD_TOKEN=your_discord_bot_token_here
DISCORD_CLIENT_ID=your_discord_client_id_here
```

### 4. Test the Bot

```bash
python discord-bot/test_bot.py
```

## Available Discord Commands

Once set up, your bot can perform various actions through Claude Desktop:

### Server Management
- List all Discord servers
- Get detailed server information
- List all channels
- List server members and roles

### Message Operations
- Send messages to channels
- Read recent message history
- Add/remove reactions
- Search messages
- Delete messages (with proper permissions)

### User Management
- Get user information
- Add/remove roles
- Timeout users (with proper permissions)

### Channel Management
- Create new text channels
- Delete channels (with proper permissions)

## Example Use Cases

### 1. Trading Alerts

**Prompt to Claude:**
```
Send a message to the #trading-alerts channel saying "BTC just broke $50,000 resistance level! Current price: $50,250. This is a significant milestone."
```

### 2. Portfolio Updates

**Prompt to Claude:**
```
Check the #portfolio-updates channel for the last 5 messages and summarize the portfolio changes mentioned.
```

### 3. Community Engagement

**Prompt to Claude:**
```
Search for messages in the #discussion channel containing "MCP" or "trading strategy" from the last 24 hours and provide a summary of the key points discussed.
```

### 4. Automated Notifications

**Prompt to Claude:**
```
Send an alert to #market-news channel: "🚨 IMPORTANT: Major market update - Ethereum 2.0 upgrade scheduled for next week. Prepare your positions accordingly."
```

## Troubleshooting

### Bot Not Connecting

**Issue**: `LoginFailure` error

**Solution**:
- Verify your Discord bot token is correct
- Check that you copied the entire token (no extra spaces)
- Ensure you enabled all required intents

### Missing Intents Error

**Issue**: `PrivilegedIntentsRequired` error

**Solution**:
- Go to Discord Developer Portal
- Enable MESSAGE CONTENT, PRESENCE, and SERVER MEMBERS intents
- Click "Save Changes"

### Claude Desktop Not Recognizing Bot

**Issue**: Bot doesn't appear in Claude Desktop

**Solution**:
- Verify Claude Desktop config file path
- Check JSON syntax (no trailing commas)
- Ensure UV is installed and accessible
- Restart Claude Desktop after making changes
- Check Claude Desktop logs for errors

### Python Version Issues

**Issue**: Import errors with audioop

**Solution**:
```bash
# For Python 3.13+
uv pip install audioop-lts
```

### Permission Denied Errors

**Issue**: Bot can't send messages or read channels

**Solution**:
- Verify bot has proper permissions in Discord server
- Check OAuth2 scopes during bot invitation
- Ensure channel permissions allow bot access

## Security Best Practices

1. **Never commit your Discord bot token** to GitHub
2. **Use environment variables** for all sensitive data
3. **Rotate your bot token** regularly (every 90 days)
4. **Limit bot permissions** to only what's necessary
5. **Monitor bot activity** for unusual behavior
6. **Use separate tokens** for development and production
7. **Enable 2FA** on your Discord account

## GitHub Automation

The project includes automatic push/pull workflows:

### Auto Pull (Every Hour)
- Automatically pulls latest changes from GitHub
- Runs on schedule: 0 * * * * (every hour)
- Can be triggered manually

### Auto Push
- Automatically pushes changes when files are modified
- Monitors: discord-bot/, logs/, .env.local
- Can be triggered manually with custom commit message

### Manual Trigger

Go to GitHub → Actions → Select workflow → Run workflow

## Project Structure

```
RUBA-Trader/
├── discord-bot/              # Discord integration
│   ├── mcp-discord/        # MCP Discord bot library
│   ├── config/             # Configuration files
│   ├── init_bot.py         # Initialization script
│   └── test_bot.py        # Testing script
├── .github/
│   └── workflows/          # GitHub Actions
│       ├── auto-pull.yml    # Auto pull workflow
│       └── auto-push.yml    # Auto push workflow
├── .env                   # Environment variables (not committed)
├── DISCORD_BOT_PLAN.md     # Detailed planning document
├── DISCORD_BOT_README.md   # This file
└── discord-bot-setup.sh     # Setup automation script
```

## Next Steps

1. ✅ Complete the setup process
2. 📚 Read `DISCORD_BOT_PLAN.md` for detailed planning
3. 🧪 Test all bot features
4. 🚀 Integrate with trading bot functionality
5. 📊 Set up monitoring and logging
6. 🤖 Implement AI-powered features
7. 📖 Create documentation for users

## Getting Help

- **Discord Developer Portal**: https://discord.com/developers/docs
- **MCP Documentation**: https://github.com/modelcontextprotocol/modelcontextprotocol
- **mcp-discord Repository**: https://github.com/hanweg/mcp-discord
- **Claude Documentation**: https://docs.anthropic.com/claude/docs/mcp

## Support

For issues or questions:
1. Check this README's troubleshooting section
2. Review `DISCORD_BOT_PLAN.md` for detailed information
3. Check GitHub Issues in the repository
4. Consult MCP and Discord API documentation

---

**Last Updated**: January 20, 2026
**Version**: 1.0
**Status**: ✅ Ready for Setup
