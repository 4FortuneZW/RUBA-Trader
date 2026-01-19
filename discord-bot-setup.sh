#!/bin/bash

# Discord Bot Setup Script for RUBA Trader
# This script automates the setup of the Discord MCP bot integration

set -e  # Exit on error

echo "========================================="
echo "RUBA Trader Discord Bot Setup"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# Check prerequisites
print_info "Checking prerequisites..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
print_success "Python $PYTHON_VERSION installed"

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git."
    exit 1
fi

print_success "Git is installed"

# Check if UV is installed, if not install it
if ! command -v uv &> /dev/null; then
    print_warning "UV is not installed. Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    print_success "UV installed successfully"
else
    print_success "UV is already installed"
fi

echo ""
print_info "Installing mcp-discord..."

# Create discord-bot directory if it doesn't exist
if [ ! -d "discord-bot" ]; then
    mkdir -p discord-bot
    print_success "Created discord-bot directory"
fi

cd discord-bot

# Clone mcp-discord repository
if [ ! -d "mcp-discord" ]; then
    print_info "Cloning mcp-discord repository..."
    git clone https://github.com/hanweg/mcp-discord.git
    print_success "mcp-discord repository cloned"
else
    print_warning "mcp-discord directory already exists. Pulling latest changes..."
    cd mcp-discord
    git pull
    cd ..
fi

cd mcp-discord

# Create virtual environment
print_info "Creating virtual environment..."
if [ ! -d ".venv" ]; then
    uv venv
    print_success "Virtual environment created"
else
    print_success "Virtual environment already exists"
fi

# Activate virtual environment
print_info "Activating virtual environment..."
source .venv/bin/activate

# Install package in development mode
print_info "Installing mcp-discord package..."
uv pip install -e .
print_success "Package installed successfully"

# Install audioop-lts for Python 3.13+
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 13 ]; then
    print_info "Python 3.13+ detected. Installing audioop-lts..."
    uv pip install audioop-lts
    print_success "audioop-lts installed"
fi

# Return to project root
cd ../..

# Create environment file template
print_info "Creating environment file template..."

if [ ! -f ".env.example" ]; then
    cat > .env.example << 'EOF'
# Discord Bot Configuration
DISCORD_TOKEN=your_discord_bot_token_here
DISCORD_CLIENT_ID=your_discord_client_id_here

# Trading Bot Configuration (if applicable)
TRADING_API_KEY=your_trading_api_key_here
TRADING_API_SECRET=your_trading_api_secret_here

# Claude Desktop Configuration
CLAUDE_DESKTOP_CONFIG_PATH=~/.config/Claude/claude_desktop_config.json

# Optional: Server and Channel Restrictions
ALLOWED_GUILD_IDS=
ALLOWED_CHANNEL_IDS=

# Optional: Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_PER_MINUTE=60
EOF
    print_success "Created .env.example file"
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    print_warning "Created .env file. Please update it with your Discord bot token."
    print_warning "Run: nano .env (or your preferred editor)"
else
    print_success ".env file already exists"
fi

# Create Claude Desktop configuration
print_info "Creating Claude Desktop configuration template..."

if [ ! -f "claude_desktop_config.json" ]; then
    cat > claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "discord": {
      "command": "uv",
      "args": [
        "--directory",
        "discord-bot/mcp-discord",
        "run",
        "mcp-discord"
      ],
      "env": {
        "DISCORD_TOKEN": "your_discord_bot_token_here"
      }
    }
  }
}
EOF
    print_success "Created claude_desktop_config.json template"
else
    print_success "claude_desktop_config.json already exists"
fi

# Create Discord bot initialization script
print_info "Creating Discord bot initialization script..."

cat > discord-bot/init_bot.py << 'EOF'
#!/usr/bin/env python3
"""
Discord Bot Initialization Script for RUBA Trader
This script helps verify your Discord bot configuration.
"""

import os
import sys
from pathlib import Path

def check_env_file():
    """Check if .env file exists and has required variables."""
    env_path = Path(__file__).parent.parent / ".env"
    
    if not env_path.exists():
        print("❌ .env file not found!")
        print(f"   Expected location: {env_path}")
        print("   Please copy .env.example to .env and fill in your credentials.")
        return False
    
    print("✓ .env file found")
    
    # Load and check environment variables
    from dotenv import load_dotenv
    load_dotenv(env_path)
    
    required_vars = ['DISCORD_TOKEN']
    missing_vars = []
    
    for var in required_vars:
        value = os.getenv(var)
        if not value or value == f"your_{var.lower()}_here":
            missing_vars.append(var)
    
    if missing_vars:
        print("❌ Missing or placeholder values for:")
        for var in missing_vars:
            print(f"   - {var}")
        return False
    
    print("✓ All required environment variables are set")
    return True

def check_discord_intents():
    """Check Discord bot configuration."""
    token = os.getenv('DISCORD_TOKEN')
    
    if not token:
        print("❌ DISCORD_TOKEN not set")
        return False
    
    print("✓ DISCORD_TOKEN is set")
    
    # Check token format
    if not token.startswith(("MTAw", "MTEw", "MTIw", "MTMw")):
        print("⚠ Token format looks unusual. Please verify it's correct.")
    else:
        print("✓ Token format looks valid")
    
    return True

def print_next_steps():
    """Print next steps for the user."""
    print("\n" + "="*60)
    print("Next Steps:")
    print("="*60)
    print("\n1. Create Discord Bot:")
    print("   - Go to https://discord.com/developers/applications")
    print("   - Create a new application")
    print("   - Create a bot user")
    print("   - Enable these intents:")
    print("     ✓ MESSAGE CONTENT INTENT")
    print("     ✓ PRESENCE INTENT")
    print("     ✓ SERVER MEMBERS INTENT")
    print()
    print("2. Invite Bot to Server:")
    print("   - Use OAuth2 URL Generator")
    print("   - Select bot scope and required permissions")
    print("   - Copy URL and open in browser")
    print("   - Authorize bot for your server")
    print()
    print("3. Configure Claude Desktop:")
    print("   - Copy your Discord bot token")
    print("   - Update claude_desktop_config.json")
    print("   - Restart Claude Desktop")
    print()
    print("4. Test Bot:")
    print("   - Run: python discord-bot/test_bot.py")
    print("   - Check for successful connection")
    print()

def main():
    print("RUBA Trader Discord Bot Configuration Check")
    print("="*60)
    print()
    
    # Install required packages
    try:
        import discord
        import python_dotenv
    except ImportError:
        print("Installing required packages...")
        import subprocess
        subprocess.run([
            sys.executable, "-m", "pip", "install",
            "discord.py", "python-dotenv"
        ], check=True)
        print("✓ Required packages installed")
        print()
    
    # Run checks
    env_ok = check_env_file()
    discord_ok = check_discord_intents()
    
    print()
    if env_ok and discord_ok:
        print("✓ Configuration looks good!")
        print_next_steps()
        return 0
    else:
        print("❌ Configuration issues found. Please fix them before continuing.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
EOF

    chmod +x discord-bot/init_bot.py
    print_success "Created Discord bot initialization script"
fi

# Create test script
print_info "Creating test script..."

cat > discord-bot/test_bot.py << 'EOF'
#!/usr/bin/env python3
"""
Test script for Discord bot connection
"""

import asyncio
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_discord_connection():
    """Test Discord bot connection."""
    try:
        import discord
        from discord import Intents
        from dotenv import load_dotenv
        import os
        
        # Load environment variables
        env_path = Path(__file__).parent.parent / ".env"
        load_dotenv(env_path)
        
        token = os.getenv('DISCORD_TOKEN')
        
        if not token:
            print("❌ DISCORD_TOKEN not found in .env file")
            return False
        
        print("Testing Discord bot connection...")
        print(f"Token: {token[:10]}...{token[-10:]}")
        print()
        
        # Define intents
        intents = discord.Intents.default()
        intents.message_content = True
        intents.presences = True
        intents.members = True
        
        # Create bot
        bot = discord.Client(intents=intents, heartbeat_timeout=60)
        
        @bot.event
        async def on_ready():
            print(f"✓ Bot connected successfully!")
            print(f"  Bot name: {bot.user.name}")
            print(f"  Bot ID: {bot.user.id}")
            print(f"  Connected to {len(bot.guilds)} servers")
            
            if bot.guilds:
                print("\n  Servers:")
                for guild in bot.guilds:
                    print(f"    - {guild.name} (ID: {guild.id})")
            
            await bot.close()
        
        @bot.event
        async def on_error(event, *args, **kwargs):
            print(f"❌ Error in {event}: {args}")
            await bot.close()
        
        # Run bot
        bot.run(token)
        return True
        
    except discord.errors.LoginFailure:
        print("❌ Failed to login. Check your DISCORD_TOKEN.")
        return False
    except discord.errors.PrivilegedIntentsRequired:
        print("❌ Privileged intents required.")
        print("   Please enable MESSAGE CONTENT, PRESENCE, and SERVER MEMBERS intents")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("RUBA Trader Discord Bot Test")
    print("="*60)
    print()
    
    success = asyncio.run(test_discord_connection())
    
    print()
    if success:
        print("✓ Test completed successfully!")
        return 0
    else:
        print("❌ Test failed. Please check the error messages above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
EOF

    chmod +x discord-bot/test_bot.py
    print_success "Created test script"

# Final summary
echo ""
echo "========================================="
print_success "Setup completed successfully!"
echo "========================================="
echo ""
print_info "Next steps:"
echo ""
echo "1. Edit .env file with your Discord bot credentials:"
echo "   nano .env  (or your preferred editor)"
echo ""
echo "2. Create your Discord bot at:"
echo "   https://discord.com/developers/applications"
echo ""
echo "3. Enable required intents:"
echo "   ✓ MESSAGE CONTENT INTENT"
echo "   ✓ PRESENCE INTENT"
echo "   ✓ SERVER MEMBERS INTENT"
echo ""
echo "4. Run initialization script:"
echo "   python discord-bot/init_bot.py"
echo ""
echo "5. Test the bot connection:"
echo "   python discord-bot/test_bot.py"
echo ""
echo "6. Configure Claude Desktop:"
echo "   - Copy discord-bot/claude_desktop_config.json to:"
echo "     ~/.config/Claude/claude_desktop_config.json (Linux)"
echo "     ~/Library/Application Support/Claude/claude_desktop_config.json (macOS)"
echo "     %APPDATA%\\Claude\\claude_desktop_config.json (Windows)"
echo "   - Update DISCORD_TOKEN with your actual token"
echo "   - Restart Claude Desktop"
echo ""
echo "For detailed information, see DISCORD_BOT_PLAN.md"
echo ""
