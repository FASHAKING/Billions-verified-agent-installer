# ============================================================
#  Verified Agent Identity — All-in-One Installer for Windows
#  GitHub: https://github.com/FASHAKING/Billions-verified-agent-installer
#
#  Usage (run in PowerShell or Windows Terminal):
#    irm https://raw.githubusercontent.com/FASHAKING/Billions-verified-agent-installer/main/install-agent-windows.ps1 | iex
#
#  What this script does:
#    1. Checks for Node.js and Git (installs via winget if missing)
#    2. Clones the verified-agent-identity repo
#    3. Installs all dependencies (including common missing ones)
#    4. Creates your Agent Ethereum Identity
#    5. Links your Human Identity with your Agent
# ============================================================

$ErrorActionPreference = "Stop"

# --- Ensure scripts like npm.ps1 can run in this session ---
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# --- Colors via ANSI escape codes (Windows Terminal supports these) ---
function Write-Banner {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║                                                          ║" -ForegroundColor Cyan
    Write-Host "  ║   Verified Agent Identity — Windows Installer            ║" -ForegroundColor Cyan
    Write-Host "  ║   by BillionsNetwork                                     ║" -ForegroundColor Cyan
    Write-Host "  ║                                                          ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$StepNum, [string]$StepDesc)
    Write-Host ""
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "    STEP $StepNum : $StepDesc" -ForegroundColor Green
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
}

function Write-Success { param([string]$Msg) Write-Host "    [OK] $Msg" -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host "    [!]  $Msg" -ForegroundColor Yellow }
function Write-Err     { param([string]$Msg) Write-Host "    [X]  $Msg" -ForegroundColor Red }
function Write-Info    { param([string]$Msg) Write-Host "    [i]  $Msg" -ForegroundColor Cyan }

# ============================================================
#  START
# ============================================================

Write-Banner

# --- Prompt user for agent details upfront ---
Write-Host "  Before we begin, let's set up your agent details:" -ForegroundColor White
Write-Host ""

do {
    $AgentName = Read-Host "    Enter your Agent Name (e.g., MyAgent)"
    if ([string]::IsNullOrWhiteSpace($AgentName)) { Write-Warn "Agent name cannot be empty." }
} while ([string]::IsNullOrWhiteSpace($AgentName))

do {
    $AgentDesc = Read-Host "    Enter your Agent Description (e.g., AI trading agent)"
    if ([string]::IsNullOrWhiteSpace($AgentDesc)) { Write-Warn "Agent description cannot be empty." }
} while ([string]::IsNullOrWhiteSpace($AgentDesc))

Write-Host ""
Write-Info "Agent Name: $AgentName"
Write-Info "Agent Description: $AgentDesc"
Write-Host ""

$Confirm = Read-Host "    Proceed with installation? (y/n)"
if ($Confirm -ne "y" -and $Confirm -ne "Y") {
    Write-Warn "Installation cancelled by user."
    exit 0
}

# ============================================================
#  STEP 1: Check / Install Node.js and Git
# ============================================================
Write-Step "1/5" "Checking for Node.js and Git"

# --- Check Node.js ---
$NodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $NodeCmd) {
    Write-Warn "Node.js not found. Attempting to install via winget..."
    $HasWinget = Get-Command winget -ErrorAction SilentlyContinue
    if ($HasWinget) {
        # Try user-scope first (no admin/UAC prompt required)
        Write-Info "Trying user-scope install (no admin required)..."
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --scope user 2>$null
        $WingetExit = $LASTEXITCODE
        if ($WingetExit -ne 0) {
            Write-Warn "User-scope install not available. Trying machine-scope (may require admin)..."
            winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
            $WingetExit = $LASTEXITCODE
        }
        if ($WingetExit -ne 0) {
            Write-Err "Node.js installation failed (exit code: $WingetExit)."
            Write-Err "Please install Node.js manually from https://nodejs.org and re-run this script."
            exit 1
        }
        # Refresh PATH so node is available in this session
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        $NodeCmd = Get-Command node -ErrorAction SilentlyContinue
        if (-not $NodeCmd) {
            Write-Warn "Node.js was installed but 'node' is not yet in PATH."
            Write-Err "Please close and reopen your terminal, then re-run this script."
            exit 1
        }
    } else {
        Write-Err "winget is not available. Please install Node.js manually from https://nodejs.org"
        exit 1
    }
}
$NodeVersion = node -v
$NpmVersion  = npm -v
Write-Success "Node.js version: $NodeVersion"
Write-Success "npm version: $NpmVersion"

# --- Check Git ---
$GitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $GitCmd) {
    Write-Warn "Git not found. Attempting to install via winget..."
    $HasWinget = Get-Command winget -ErrorAction SilentlyContinue
    if ($HasWinget) {
        # Try user-scope first (no admin/UAC prompt required)
        Write-Info "Trying user-scope install (no admin required)..."
        winget install Git.Git --accept-source-agreements --accept-package-agreements --scope user 2>$null
        $WingetExit = $LASTEXITCODE
        if ($WingetExit -ne 0) {
            Write-Warn "User-scope install not available. Trying machine-scope (may require admin)..."
            winget install Git.Git --accept-source-agreements --accept-package-agreements
            $WingetExit = $LASTEXITCODE
        }
        if ($WingetExit -ne 0) {
            Write-Err "Git installation failed (exit code: $WingetExit)."
            Write-Err "Please install Git manually from https://git-scm.com and re-run this script."
            exit 1
        }
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        $GitCmd = Get-Command git -ErrorAction SilentlyContinue
        if (-not $GitCmd) {
            Write-Warn "Git was installed but 'git' is not yet in PATH."
            Write-Err "Please close and reopen your terminal, then re-run this script."
            exit 1
        }
    } else {
        Write-Err "winget is not available. Please install Git manually from https://git-scm.com"
        exit 1
    }
}
$GitVersion = git --version
Write-Success "Git version: $GitVersion"

# ============================================================
#  STEP 2: Clone the Repository
# ============================================================
Write-Step "2/5" "Cloning verified-agent-identity repository"

$InstallDir = Join-Path $HOME "verified-agent-identity"

if (Test-Path $InstallDir) {
    Write-Warn "Existing folder found. Removing for a fresh install..."
    Remove-Item -Recurse -Force $InstallDir
}

git clone https://github.com/BillionsNetwork/verified-agent-identity.git $InstallDir
Set-Location $InstallDir

Write-Success "Repository cloned successfully."
Write-Info "Working directory: $(Get-Location)"

# ============================================================
#  STEP 3: Install Dependencies via clawhub
# ============================================================
Write-Step "3/5" "Installing project dependencies via clawhub"

npx --yes clawhub@latest install verified-agent-identity

Write-Success "clawhub dependencies installed."

# --- Pre-install commonly missing modules ---
Write-Info "Installing commonly required modules to prevent errors..."

npm install shell-quote
Write-Success "Installed: shell-quote"

npm install @iden3/js-iden3-auth
Write-Success "Installed: @iden3/js-iden3-auth"

npm install ethers@6
Write-Success "Installed: ethers v6 (required for SigningKey support)"

npm install uuid
Write-Success "Installed: uuid (required for message ID generation)"

Write-Success "All dependencies installed."

# ============================================================
#  STEP 4: Create Agent Ethereum Identity
# ============================================================
Write-Step "4/5" "Creating your Agent Ethereum Identity"

node scripts/createNewEthereumIdentity.js

Write-Success "Agent Ethereum identity created."

# ============================================================
#  STEP 5: Link Human Identity with Agent
# ============================================================
Write-Step "5/5" "Linking Human Identity with your Agent"

Write-Host ""
Write-Info "Using Agent Name: $AgentName"
Write-Info "Using Agent Description: $AgentDesc"
Write-Host ""

# Pass challenge JSON via env var to avoid PowerShell quoting issues with external commands
$env:AGENT_CHALLENGE = ConvertTo-Json -Compress @{ name = $AgentName; description = $AgentDesc }
node -e "const cp = require('child_process'); cp.execFileSync('node', ['scripts/manualLinkHumanToAgent.js', '--challenge', process.env.AGENT_CHALLENGE], {stdio: 'inherit'})"

# ============================================================
#  DONE
# ============================================================
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ║    Installation Complete!                                ║" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ╠══════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ║   NEXT STEPS:                                            ║" -ForegroundColor Green
Write-Host "  ║   1. Copy the verification URL from above                ║" -ForegroundColor Green
Write-Host "  ║   2. Open it in your browser                             ║" -ForegroundColor Green
Write-Host "  ║   3. Connect your wallet                                 ║" -ForegroundColor Green
Write-Host "  ║   4. Verify — and you're done!                           ║" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
