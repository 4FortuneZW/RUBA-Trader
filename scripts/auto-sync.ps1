###############################################################################
# RUBA Trader - Automated GitHub Sync Script (PowerShell)
# 
# This script automatically syncs the local repository with the remote
# GitHub repository. It handles conflicts and commits local changes.
#
# Usage: .\scripts\auto-sync.ps1 [options]
#
# Options:
#   -Help               Show this help message
#   -Force              Force pull from remote (may discard local changes)
#   -Verbose            Enable verbose output
#   -DryRun             Run without making changes
#
###############################################################################

param(
    [switch]$Help,
    [switch]$Force,
    [switch]$Verbose,
    [switch]$DryRun
)

# Show help
if ($Help) {
    Write-Host "RUBA Trader - Automated GitHub Sync Script (PowerShell)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\scripts\auto-sync.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help               Show this help message"
    Write-Host "  -Force              Force pull from remote (may discard local changes)"
    Write-Host "  -Verbose            Enable verbose output"
    Write-Host "  -DryRun             Run without making changes"
    Write-Host ""
    exit 0
}

# Helper functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Enable verbose output
if ($Verbose) {
    $VerbosePreference = "Continue"
}

# Check if we're in a git repository
$gitDir = git rev-parse --git-dir 2>$null
if (-not $gitDir) {
    Write-Error "Not in a git repository"
    exit 1
}

# Get the current branch
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Info "Current branch: $currentBranch"

# Fetch latest changes from remote
Write-Info "Fetching latest changes from remote..."
if ($DryRun) {
    Write-Info "[DRY RUN] Would fetch from remote"
} else {
    git fetch --all
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to fetch from remote"
        exit 1
    }
}
Write-Success "Fetched successfully"

# Check if there are local changes
$status = git status --porcelain
if ($status) {
    Write-Warning "Found uncommitted changes"
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would commit changes"
    } else {
        # Stage all changes
        Write-Info "Staging changes..."
        git add .
        
        # Commit changes
        Write-Info "Committing changes..."
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        git commit -m "chore: auto-sync $timestamp"
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to commit changes"
            exit 1
        }
        
        Write-Success "Changes committed"
    }
} else {
    Write-Info "No local changes to commit"
}

# Pull latest changes
Write-Info "Pulling latest changes from origin/$currentBranch..."
if ($DryRun) {
    Write-Info "[DRY RUN] Would pull from remote"
} else {
    if ($Force) {
        Write-Warning "Force pulling (may discard local changes)..."
        git reset --hard "origin/$currentBranch"
    } else {
        # Try to pull with rebase
        $pullResult = git pull --rebase origin $currentBranch 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Merge or rebase conflicts detected"
            Write-Warning "Resolve conflicts manually, then run: git rebase --continue"
            exit 1
        }
    }
    Write-Success "Pulled successfully"
}

# Push local commits to remote
Write-Info "Pushing changes to remote..."
if ($DryRun) {
    Write-Info "[DRY RUN] Would push to remote"
} else {
    git push origin $currentBranch
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to push to remote"
        exit 1
    }
    Write-Success "Pushed successfully"
}

# Display sync summary
$lastCommit = git log -1 --pretty=format:'%h - %an, %ar : %s'
Write-Info "Sync Summary:"
Write-Info "  Branch: $currentBranch"
Write-Info "  Latest commit: $lastCommit"

# Show status
if ($Verbose) {
    Write-Info "Repository status:"
    git status
}

Write-Success "Sync completed successfully!"
