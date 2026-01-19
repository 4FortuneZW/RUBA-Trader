#!/bin/bash

###############################################################################
# RUBA Trader - Automated GitHub Sync Script
# 
# This script automatically syncs the local repository with the remote
# GitHub repository. It handles conflicts and commits local changes.
#
# Usage: ./scripts/auto-sync.sh [options]
#
# Options:
#   -h, --help          Show this help message
#   -f, --force         Force pull from remote (may discard local changes)
#   -v, --verbose       Enable verbose output
#   -n, --dry-run       Run without making changes
#
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
FORCE=false
VERBOSE=false
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "RUBA Trader - Automated GitHub Sync Script"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -h, --help          Show this help message"
            echo "  -f, --force         Force pull from remote (may discard local changes)"
            echo "  -v, --verbose       Enable verbose output"
            echo "  -n, --dry-run       Run without making changes"
            echo ""
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            set -x
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
fi

# Get the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
log_info "Current branch: $CURRENT_BRANCH"

# Fetch latest changes from remote
log_info "Fetching latest changes from remote..."
if [ "$DRY_RUN" = true ]; then
    log_info "[DRY RUN] Would fetch from remote"
else
    git fetch --all
fi
log_success "Fetched successfully"

# Check if there are local changes
if [ -n "$(git status --porcelain)" ]; then
    log_warning "Found uncommitted changes"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would commit changes"
    else
        # Stage all changes
        log_info "Staging changes..."
        git add .
        
        # Commit changes
        log_info "Committing changes..."
        TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
        git commit -m "chore: auto-sync $TIMESTAMP"
        
        log_success "Changes committed"
    fi
else
    log_info "No local changes to commit"
fi

# Pull latest changes
log_info "Pulling latest changes from origin/$CURRENT_BRANCH..."
if [ "$DRY_RUN" = true ]; then
    log_info "[DRY RUN] Would pull from remote"
else
    if [ "$FORCE" = true ]; then
        log_warning "Force pulling (may discard local changes)..."
        git reset --hard origin/$CURRENT_BRANCH
    else
        # Try to pull with rebase
        if git pull --rebase origin $CURRENT_BRANCH 2>/dev/null; then
            log_success "Pulled successfully"
        else
            log_error "Merge or rebase conflicts detected"
            log_warning "Resolve conflicts manually, then run: git rebase --continue"
            exit 1
        fi
    fi
fi

# Push local commits to remote
log_info "Pushing changes to remote..."
if [ "$DRY_RUN" = true ]; then
    log_info "[DRY RUN] Would push to remote"
else
    git push origin $CURRENT_BRANCH
    log_success "Pushed successfully"
fi

# Display sync summary
log_info "Sync Summary:"
log_info "  Branch: $CURRENT_BRANCH"
log_info "  Latest commit: $(git log -1 --pretty=format:'%h - %an, %ar : %s')"

# Show status
if [ "$VERBOSE" = true ]; then
    log_info "Repository status:"
    git status
fi

log_success "Sync completed successfully!"
