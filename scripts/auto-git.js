const { SimpleGit } = require('simple-git');
const cron = require('node-cron');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

class AutoGit {
  constructor() {
    this.git = new SimpleGit();
    this.logFile = path.join(__dirname, '../logs/git-automation.log');
    this.config = {
      username: process.env.GITHUB_USERNAME,
      repo: process.env.GITHUB_REPO,
      branch: process.env.GITHUB_BRANCH || 'main',
      autoSync: process.env.GITHUB_AUTO_SYNC === 'true',
      syncInterval: parseInt(process.env.GITHUB_SYNC_INTERVAL) || 30,
    };
  }

  log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}\n`;
    
    // Ensure logs directory exists
    const logsDir = path.dirname(this.logFile);
    if (!fs.existsSync(logsDir)) {
      fs.mkdirSync(logsDir, { recursive: true });
    }
    
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
        tracking: status.tracking,
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

      // Check if there are staged changes
      const status = await this.git.status();
      if (status.staging.length === 0) {
        this.log('ℹ️  No changes to commit');
        return true;
      }

      // Commit
      await this.git.commit(message);
      this.log('✅ Changes committed');

      // Push
      await this.git.push('origin', this.config.branch);
      this.log(`✅ Changes pushed to origin/${this.config.branch}`);

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
        await this.git.pull('origin', this.config.branch);
        this.log('✅ Changes pulled successfully');

        // Trigger reload if callback is set
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
      this.log('🔄 Starting sync check...');

      // Check for local changes
      const status = await this.getStatus();

      if (status.files.length > 0) {
        // Auto-commit local changes
        const filesChanged = status.files.map(f => f.path).join(', ');
        const commitMessage = `Auto-commit: ${filesChanged.substring(0, 100)}`;
        await this.commitAndPush(commitMessage);
      }

      // Check for remote changes
      await this.pullAndReload();

      this.log('✅ Sync check completed');
    } catch (error) {
      this.log(`❌ Sync failed: ${error.message}`);
    }
  }

  startAutoSync() {
    if (!this.config.autoSync) {
      this.log('ℹ️  Auto-sync is disabled in configuration');
      return;
    }

    this.log(`🔄 Starting auto-sync (every ${this.config.syncInterval} minutes)`);

    // Schedule auto-sync
    cron.schedule(`*/${this.config.syncInterval} * * * *`, () => {
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
  }).catch(error => {
    console.error('Error:', error);
    process.exit(1);
  });
}
