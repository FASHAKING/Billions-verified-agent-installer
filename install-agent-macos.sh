#!/usr/bin/env bash

# ============================================================
#  Verified Agent Identity — Installer for macOS
#  GitHub: https://github.com/FASHAKING/Billions-verified-agent-installer
#
#  Usage:
#    curl -sL https://raw.githubusercontent.com/FASHAKING/Billions-verified-agent-installer/main/install-agent-macos.sh | bash
#
#  Supported environments:
#    - macOS (Apple Silicon & Intel)
#
#  What this script does:
#    1. Installs Homebrew, Node.js, and Git if not already present
#    2. Clones the verified-agent-identity repo
#    3. Installs all dependencies (including common missing ones)
#    4. Creates your Agent Ethereum Identity
#    5. Links your Human Identity with your Agent
# ============================================================

set -e  # Exit immediately if any command fails

# --- Colors for terminal output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Helper functions ---
print_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║   ${BOLD}Verified Agent Identity — macOS Installer${NC}${CYAN}              ║${NC}"
    echo -e "${CYAN}║   ${NC}by BillionsNetwork${CYAN}                                     ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  STEP $1: $2${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}  [OK] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  [!]  $1${NC}"
}

print_error() {
    echo -e "${RED}  [X]  $1${NC}"
}

print_info() {
    echo -e "${CYAN}  [i]  $1${NC}"
}

# ============================================================
#  START
# ============================================================

print_banner

# --- Check we're on macOS ---
if [ "$(uname)" != "Darwin" ]; then
    print_error "This script is for macOS only."
    print_info "For Linux/WSL, use: install-agent-codespaces.sh"
    print_info "For Termux, use: install-agent.sh"
    exit 1
fi

print_info "Detected: macOS $(sw_vers -productVersion 2>/dev/null || echo '')"

# --- Prompt user for agent details upfront ---
echo -e "${BOLD}Before we begin, let's set up your agent details:${NC}"
echo ""

read -p "  Enter your Agent Name (e.g., MyAgent): " AGENT_NAME < /dev/tty
while [ -z "$AGENT_NAME" ]; do
    print_warning "Agent name cannot be empty."
    read -p "  Enter your Agent Name: " AGENT_NAME < /dev/tty
done

read -p "  Enter your Agent Description (e.g., AI trading agent): " AGENT_DESC < /dev/tty
while [ -z "$AGENT_DESC" ]; do
    print_warning "Agent description cannot be empty."
    read -p "  Enter your Agent Description: " AGENT_DESC < /dev/tty
done

echo ""
print_info "Agent Name: ${AGENT_NAME}"
print_info "Agent Description: ${AGENT_DESC}"
echo ""
read -p "  Proceed with installation? (y/n): " CONFIRM < /dev/tty
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo ""
    print_warning "Installation cancelled by user."
    exit 0
fi

# ============================================================
#  STEP 1: Install Homebrew, Node.js, and Git
# ============================================================
print_step "1/5" "Checking and installing Homebrew, Node.js, and Git"

# --- Install Homebrew if not present ---
if command -v brew &>/dev/null; then
    print_success "Homebrew already installed: $(brew --version | head -1)"
else
    print_info "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty

    # Add Homebrew to PATH for Apple Silicon Macs
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew &>/dev/null; then
        print_error "Homebrew installation failed. Please install manually: https://brew.sh"
        exit 1
    fi
    print_success "Homebrew installed."
fi

# --- Install Node.js if not present ---
if command -v node &>/dev/null; then
    print_success "Node.js already installed: $(node -v)"
else
    print_info "Node.js not found. Installing via Homebrew..."
    brew install node
    if ! command -v node &>/dev/null; then
        print_error "Node.js installation failed. Please install manually: https://nodejs.org"
        exit 1
    fi
    print_success "Node.js installed: $(node -v)"
fi

# --- Install Git if not present ---
if command -v git &>/dev/null; then
    print_success "Git already installed: $(git --version)"
else
    print_info "Git not found. Installing via Homebrew..."
    brew install git
    print_success "Git installed: $(git --version)"
fi

NODE_VERSION=$(node -v 2>/dev/null)
NPM_VERSION=$(npm -v 2>/dev/null)
GIT_VERSION=$(git --version 2>/dev/null)

print_success "Node.js version: ${NODE_VERSION}"
print_success "npm version: ${NPM_VERSION}"
print_success "Git version: ${GIT_VERSION}"

# ============================================================
#  STEP 2: Clone the Repository
# ============================================================
print_step "2/5" "Cloning verified-agent-identity repository"

cd "$HOME"

if [ -d "verified-agent-identity" ]; then
    print_warning "Existing folder found. Removing for a fresh install..."
    rm -rf verified-agent-identity
fi

git clone https://github.com/BillionsNetwork/verified-agent-identity.git
cd verified-agent-identity

print_success "Repository cloned successfully."
print_info "Working directory: $(pwd)"

# ============================================================
#  STEP 3: Install Dependencies via clawhub
# ============================================================
print_step "3/5" "Installing project dependencies via clawhub"

if npx --yes clawhub@latest install verified-agent-identity 2>&1; then
    print_success "clawhub dependencies installed."
else
    print_warning "clawhub failed — falling back to npm install..."
    npm install 2>&1
    print_success "npm dependencies installed."
fi

# --- Pre-install commonly missing modules ---
print_info "Installing commonly required modules to prevent errors..."

npm install shell-quote 2>&1
print_success "Installed: shell-quote"

npm install @iden3/js-iden3-auth 2>&1
print_success "Installed: @iden3/js-iden3-auth"

npm install ethers@6 2>&1
print_success "Installed: ethers v6 (required for SigningKey support)"

npm install uuid 2>&1
print_success "Installed: uuid (required for message ID generation)"

print_success "All dependencies installed."

# ============================================================
#  STEP 4: Create Agent Ethereum Identity
# ============================================================
print_step "4/5" "Creating your Agent Ethereum Identity"

node scripts/createNewEthereumIdentity.js

print_success "Agent Ethereum identity created."

# ============================================================
#  STEP 5: Link Human Identity with Agent
# ============================================================
print_step "5/5" "Linking Human Identity with your Agent"

echo ""
print_info "Using Agent Name: ${AGENT_NAME}"
print_info "Using Agent Description: ${AGENT_DESC}"
echo ""

# Build JSON safely using node to escape special characters in user input
CHALLENGE_JSON=$(node -e "console.log(JSON.stringify({name:process.argv[1],description:process.argv[2]}))" -- "$AGENT_NAME" "$AGENT_DESC")
node scripts/manualLinkHumanToAgent.js --challenge "$CHALLENGE_JSON"

# ============================================================
#  DONE
# ============================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║    Installation Complete!                                ║${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║${NC}   ${BOLD}NEXT STEPS:${NC}${GREEN}                                              ║${NC}"
echo -e "${GREEN}║${NC}   1. Copy the verification URL from above${GREEN}               ║${NC}"
echo -e "${GREEN}║${NC}   2. Open it in your browser${GREEN}                              ║${NC}"
echo -e "${GREEN}║${NC}   3. Connect your wallet${GREEN}                                  ║${NC}"
echo -e "${GREEN}║${NC}   4. Verify — and you're done!${GREEN}                            ║${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
