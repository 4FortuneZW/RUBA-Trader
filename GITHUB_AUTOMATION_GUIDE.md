# GitHub Automation Guide
## Automatic Push/Pull for RUBA Trader Discord Bot

---

## 📋 Overview

This guide explains how to set up automatic GitHub synchronization (push and pull) for the RUBA Trader Discord Bot. The automation ensures that configuration changes and bot state are automatically backed up to GitHub, and remote updates are pulled regularly.

---

## 🎯 Objectives

1. **Auto-Push**: Automatically push local changes to GitHub
2. **Auto-Pull**: Automatically pull remote changes from GitHub
3. **Conflict Handling**: Resolve conflicts intelligently
4. **Security**: Secure authentication and authorization
5. **Reliability**: Handle network failures gracefully

---

## 🔧 Setup Requirements

### Prerequisites
- Git installed and configured
- GitHub repository access
- SSH key configured (recommended) or Personal Access Token
- Node.js 18+ installed
- Linux/Mac/Windows environment

### Files Needed
- `.git/hooks/pre-commit` - Pre-commit validation
- `.git/hooks/post-commit` - Post-commit push automation
- `scripts/auto-git.js` - Node.js automation script
- `.github/workflows/auto-sync.yml` - GitHub Actions workflow

---

## 🚀 Implementation Options

### Option 1: Git Hooks (Simple & Fast)

#### Pre-commit Hook
```bash
#!/bin/bash

# .git/hooks/pre-commit

echo "🔍 Running pre-commit checks..."

# Check if sensitive files are not being committed
if git diff --cached --name-only | grep -q "\.env$"; then
    echo "❌ Error: .env files should not be committed!"
    echo "💡 Add .env to .gitignore if needed"
    exit 1
fi

# Validate JSON files
if git diff --cached --name-only | grep -q "\.json$"; then
    for file in $(git diff --cached --name-only | grep "\.json$"); do
        if ! jq empty "$file" 2>/dev/null; then
            echo "❌ Error: Invalid JSON in $file"
            exit 1
        fi
    done
fi

echo "✅ Pre-commit checks passed!"
exit 0
```

#### Post-commit Hook (Auto-Push)
```bash
#!/bin/bash

# .git/hooks/post-commit

echo "📤 Auto-pushing to GitHub..."

# Get the current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Push to remote
git push origin $BRANCH

if [ $? -eq 0 ]; then
    echo "✅ Successfully pushed to origin/$BRANCH"
else
    echo "❌ Failed to push to GitHub"
    echo "💡 Please push manually: git push origin $BRANCH"
fi
```

**How to install:**
```bash
# Make hooks executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/post-commit

# Or copy scripts
cp scripts/hooks/pre-commit .git/hooks/pre-commit
cp scripts/hooks/post-commit .git/hooks/post-commit
```

---

### Option 2: Node.js Automation (Recommended for Discord Bot)

#### Install Dependencies
```bash
npm install simple-git node-cron dotenv
```

#### Auto-Git Script
```javascript
// scripts/auto-git.js

const { SimpleGit } = require('simple-git');
const cron = require('node-cron');
const fs = require('fs');
const path = require('path');

class AutoGit {
  constructor() {
    this.git = new SimpleGit();
    this.logFile = path.join(__dirname, '../logs/git-automation.log');
  }

  log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}\n`;
    fs.appendFileSync(this.logFile, logMessage);
    console.log(logMessage.trim());
  }

  async getStatus() {
    try {
      const status = await this.git.status();
      return {
        branch: status.current,
        files: status.files,
        ahead: status.ahead,
        behind: status.behind,
        tracking: status.tracking
      };
    } catch (error) {
      this.log(`❌ Get status failed: ${error.message}`);
      throw error;
    }
  }

  async commitAndPush(message, files = '.') {
    try {
      this.log(`📝 Committing changes: ${message}`);

      // Add files
      await this.git.add(files);

      // Commit
      await this.git.commit(message);
      this.log('✅ Changes committed');

      // Push
      const branch = (await this.git.status()).current;
      await this.git.push('origin', branch);
      this.log('✅ Changes pushed to GitHub');

      return true;
    } catch (error) {
      this.log(`❌ Commit/Push failed: ${error.message}`);
      return false;
    }
  }

  async pullAndReload() {
    try {
      const status = await this.getStatus();
      
      if (status.behind > 0) {
        this.log(`📥 Pulling ${status.behind} commit(s) from GitHub...`);

        // Pull changes
        await this.git.pull('origin', status.branch);
        this.log('✅ Changes pulled successfully');

        // Reload configuration
        if (this.onReload) {
          await this.onReload();
        }

        return true;
      } else {
        this.log('✅ Already up to date');
        return false;
      }
    } catch (error) {
      this.log(`❌ Pull failed: ${error.message}`);
      return false;
    }
  }

  async checkAndSync() {
    try {
      // Check for local changes
      const status = await this.getStatus();

      if (status.files.length > 0) {
        // Auto-commit local changes
        const filesChanged = status.files.map(f => f.path).join(', ');
        await this.commitAndPush(`Auto-commit: ${filesChanged}`);
      }

      // Check for remote changes
      await this.pullAndReload();
    } catch (error) {
      this.log(`❌ Sync failed: ${error.message}`);
    }
  }

  startAutoSync(intervalMinutes = 30) {
    this.log(`🔄 Starting auto-sync (every ${intervalMinutes} minutes)`);

    // Schedule auto-sync
    cron.schedule(`*/${intervalMinutes} * * * *`, () => {
      this.checkAndSync();
    });

    // Also sync on startup
    this.checkAndSync();
  }

  setReloadCallback(callback) {
    this.onReload = callback;
  }
}

// Export for use in Discord bot
module.exports = AutoGit;

// If run directly, perform one sync
if (require.main === module) {
  const autoGit = new AutoGit();
  autoGit.checkAndSync().then(() => {
    process.exit(0);
  });
}
```

---

### Option 3: GitHub Actions (CI/CD)

#### Workflow File
```yaml
# .github/workflows/auto-sync.yml

name: Auto Sync & Deploy

on:
  push:
    branches: [main, develop]
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:       # Manual trigger

jobs:
  check-for-changes:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check for config changes
        id: check-config
        run: |
          if git diff HEAD~1 HEAD --name-only | grep -E '\.(js|json|env|yml|yaml)'; then
            echo "config_changed=true" >> $GITHUB_OUTPUT
            echo "📝 Configuration files changed"
          else
            echo "config_changed=false" >> $GITHUB_OUTPUT
            echo "✅ No configuration changes"
          fi

      - name: Run tests
        if: steps.check-config.outputs.config_changed == 'true'
        run: |
          npm install
          npm test

      - name: Notify Discord
        if: always()
        uses: discord-actions/send-message@v1
        with:
          webhook: ${{ secrets.DISCORD_WEBHOOK }}
          message: |
            🤖 RUBA Trader GitHub Sync
            Status: ${{ job.status }}
            Branch: ${{ github.ref_name }}
            Author: ${{ github.actor }}
            Message: ${{ github.event.head_commit.message }}

  deploy:
    needs: check-for-changes
    if: needs.check-for-changes.outputs.config_changed == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          echo "🚀 Deploying to production..."
          # Add deployment commands here
```

---

## 🤖 Integration with Discord Bot

### Bot Auto-Sync Integration
```javascript
// src/bot/index.js

const { Client, GatewayIntentBits } = require('discord.js');
const AutoGit = require('../scripts/auto-git');
const config = require('./config');

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
  ]
});

// Initialize auto-git
const autoGit = new AutoGit();

// Set reload callback
autoGit.setReloadCallback(async () => {
  console.log('🔄 Reloading configuration...');
  
  // Reload bot configuration
  const newConfig = require('./config');
  Object.assign(config, newConfig);
  
  // Reload commands
  await reloadCommands();
  
  console.log('✅ Configuration reloaded');
});

// Start auto-sync (every 30 minutes)
autoGit.startAutoSync(30);

// Auto-commit on config changes
client.on('interactionCreate', async (interaction) => {
  if (interaction.commandName === 'config') {
    // Handle config command
    await handleConfigCommand(interaction);
    
    // Auto-commit after config change
    await autoGit.commitAndPush(
      `Config update: ${interaction.user.username}`
    );
  }
});

// Manual sync command
const { SlashCommandBuilder } = require('@discordjs/builders');

const syncCommand = new SlashCommandBuilder()
  .setName('sync')
  .setDescription('Manual GitHub sync')
  .addSubcommand(subcommand =>
    subcommand
      .setName('push')
      .setDescription('Push local changes to GitHub')
  )
  .addSubcommand(subcommand =>
    subcommand
      .setName('pull')
      .setDescription('Pull changes from GitHub')
  );

client.on('interactionCreate', async (interaction) => {
  if (!interaction.isCommand()) return;

  if (interaction.commandName === 'sync') {
    const subcommand = interaction.options.getSubcommand();
    
    if (subcommand === 'push') {
      await interaction.reply({ content: '📤 Pushing to GitHub...', fetchReply: true });
      const success = await autoGit.commitAndPush('Manual sync: ' + interaction.user.username);
      await interaction.editReply(success ? '✅ Push successful!' : '❌ Push failed!');
    } 
    else if (subcommand === 'pull') {
      await interaction.reply({ content: '📥 Pulling from GitHub...', fetchReply: true });
      const updated = await autoGit.pullAndReload();
      await interaction.editReply(updated ? '✅ Pull successful!' : '✅ Already up to date!');
    }
  }
});
```

---

## 🔐 Security Setup

### SSH Key Setup (Recommended)
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "discord-bot" -f ~/.ssh/discord_bot_key

# Add to GitHub
# Settings > SSH and GPG keys > Add new
cat ~/.ssh/discord_bot_key.pub

# Test connection
ssh -i ~/.ssh/discord_bot_key git@github.com
```

### Personal Access Token (Alternative)
```bash
# Create PAT on GitHub
# Settings > Developer settings > Personal access tokens

# Configure git to use token
git config --global credential.helper store
git push
# Enter: https://<TOKEN>@github.com/username/repo.git
```

### Environment Variables
```bash
# .env.example
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GITHUB_USERNAME=4FortuneZW
GITHUB_REPO=RUBA-Trader
GITHUB_BRANCH=main
GITHUB_AUTO_SYNC=true
GITHUB_SYNC_INTERVAL=30
```

---

## 📊 Monitoring & Logging

### Log Structure
```
logs/
├── git-automation.log       # Git operations
├── sync-errors.log          # Sync failures
└── deployment.log          # Deployment events
```

### Monitoring Commands
```bash
# View recent git sync logs
tail -f logs/git-automation.log

# Check sync status
git status
git log --oneline -10

# Monitor file changes
watch -n 5 'git status --short'
```

### Discord Notification on Sync Events
```javascript
async function notifySync(result) {
  const channel = await client.channels.fetch(config.notificationChannel);
  
  const embed = {
    color: result.success ? 0x00FF00 : 0xFF0000,
    title: result.type === 'push' ? '📤 GitHub Push' : '📥 GitHub Pull',
    fields: [
      { name: 'Status', value: result.success ? '✅ Success' : '❌ Failed', inline: true },
      { name: 'Branch', value: result.branch, inline: true },
      { name: 'Files', value: result.files || 'None', inline: false }
    ],
    timestamp: new Date()
  };
  
  await channel.send({ embeds: [embed] });
}
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Push Fails with "Authentication Failed"
**Solution:** Check SSH keys or PAT
```bash
# Test SSH
ssh -T git@github.com

# Update remote URL
git remote set-url origin git@github.com:4FortuneZW/RUBA-Trader.git
```

#### 2. Pull Creates Merge Conflicts
**Solution:** Auto-resolve or notify admin
```javascript
async function handleConflict() {
  // Create backup
  const timestamp = new Date().toISOString();
  await this.git.commit(`Backup before conflict resolution: ${timestamp}`);
  
  // Notify admin
  await notifyAdmin('⚠️ Merge conflict detected - manual resolution required');
}
```

#### 3. Auto-Commit Creates Too Many Commits
**Solution:** Batch changes
```javascript
async function batchCommit() {
  const status = await this.git.status();
  if (status.files.length > 0) {
    // Batch all changes
    await this.git.add('.');
    await this.git.commit('Auto-commit: batch update');
    await this.git.push('origin', 'HEAD');
  }
}
```

#### 4. Hook Scripts Not Executing
**Solution:** Check file permissions
```bash
# Make executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/post-commit

# Verify
ls -la .git/hooks/
```

---

## 📈 Best Practices

1. **Commit Messages**
   - Use clear, descriptive messages
   - Include context (what changed, why)
   - Prefix with emoji for clarity

2. **Branch Management**
   - Use `main` for production
   - Use `develop` for development
   - Create feature branches for changes

3. **Change Frequency**
   - Auto-sync every 30 minutes (configurable)
   - Manual sync on critical changes
   - Batch minor changes

4. **Conflict Prevention**
   - Use `.gitignore` properly
   - Don't commit generated files
   - Separate config from code

5. **Backup Strategy**
   - Always create backup before risky operations
   - Keep last N backups
   - Test restore procedure

---

## 🚀 Quick Start

```bash
# 1. Install dependencies
npm install simple-git node-cron dotenv

# 2. Set up environment variables
cp .env.example .env
# Edit .env with your GitHub credentials

# 3. Install git hooks
chmod +x scripts/hooks/pre-commit
chmod +x scripts/hooks/post-commit
cp scripts/hooks/* .git/hooks/

# 4. Test auto-git
node scripts/auto-git.js

# 5. Start Discord bot with auto-sync
npm start

# 6. Verify
# - Check logs/git-automation.log
# - Run /sync command in Discord
# - Verify GitHub repository
```

---

## 📚 Additional Resources

- [Simple Git Documentation](https://github.com/steveukx/git-js)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Git Hooks Reference](https://git-scm.com/docs/githooks)
- [Node-cron Documentation](https://www.npmjs.com/package/node-cron)

---

**Document Version**: 1.0  
**Last Updated**: 2026-01-20  
**Status**: Ready for Implementation  
