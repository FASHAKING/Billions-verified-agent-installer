#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Verified Agent Identity — All-in-One Installer for Termux
#  GitHub: https://github.com/FASHAKING/Billions-verified-agent-installer
#
#  Usage:
#    curl -sL https://raw.githubusercontent.com/FASHAKING/Billions-verified-agent-installer/main/install-agent.sh | bash
#
#  What this script does:
#    1. Updates & upgrades Termux packages
#    2. Installs Node.js and Git
#    3. Clones the verified-agent-identity repo
#    4. Installs all dependencies (including common missing ones)
#    5. Creates your Agent Ethereum Identity
#    6. Links your Human Identity with your Agent
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
    echo -e "${CYAN}║   ${BOLD}Verified Agent Identity — Termux Installer${NC}${CYAN}             ║${NC}"
    echo -e "${CYAN}║   ${NC}by BillionsNetwork${CYAN}                                     ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✦ STEP $1: $2${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}  ✔ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}  ✖ $1${NC}"
}

print_info() {
    echo -e "${CYAN}  ℹ $1${NC}"
}

# ============================================================
#  START
# ============================================================

print_banner

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
#  STEP 1: Update & Upgrade Termux Packages
# ============================================================
print_step "1/6" "Updating & upgrading Termux packages"

# Auto-accept all prompts during update
yes | pkg update -y 2>&1
yes | pkg upgrade -y 2>&1

print_success "Termux packages updated and upgraded."

# ============================================================
#  STEP 2: Install Node.js and Git
# ============================================================
print_step "2/6" "Installing Node.js and Git"

# Install nodejs (includes npm)
yes | pkg install nodejs -y 2>&1
print_success "Node.js installed."

# Install git
yes | pkg install git -y 2>&1
print_success "Git installed."

# Verify installations
NODE_VERSION=$(node -v 2>/dev/null)
NPM_VERSION=$(npm -v 2>/dev/null)
GIT_VERSION=$(git --version 2>/dev/null)

if [ -z "$NODE_VERSION" ]; then
    print_error "Node.js installation failed. Please try manually: pkg install nodejs"
    exit 1
fi

print_success "Node.js version: ${NODE_VERSION}"
print_success "npm version: ${NPM_VERSION}"
print_success "Git version: ${GIT_VERSION}"

# ============================================================
#  STEP 3: Clone the Repository
# ============================================================
print_step "3/6" "Cloning verified-agent-identity repository"

# Go to home directory to keep things clean
cd "$HOME"

# Remove old clone if it exists (fresh install)
if [ -d "verified-agent-identity" ]; then
    print_warning "Existing folder found. Removing for a fresh install..."
    rm -rf verified-agent-identity
fi

git clone https://github.com/BillionsNetwork/verified-agent-identity.git
cd verified-agent-identity

print_success "Repository cloned successfully."
print_info "Working directory: $(pwd)"

# ============================================================
#  STEP 4: Install Dependencies via clawhub
# ============================================================
print_step "4/6" "Installing project dependencies via clawhub"

# Run the clawhub installer (auto-accept prompts)
yes | npx clawhub@latest install verified-agent-identity 2>&1

print_success "clawhub dependencies installed."

# --- Pre-install commonly missing modules to prevent errors ---
print_info "Installing commonly required modules to prevent errors..."

npm install shell-quote 2>&1
print_success "Installed: shell-quote"

npm install @iden3/js-iden3-auth 2>&1
print_success "Installed: @iden3/js-iden3-auth"

npm install ethers@6 2>&1
print_success "Installed: ethers v6 (required for SigningKey support)"

print_success "All dependencies installed."

# ============================================================
#  STEP 5: Create Agent Ethereum Identity
# ============================================================
print_step "5/6" "Creating your Agent Ethereum Identity"

node scripts/createNewEthereumIdentity.js

print_success "Agent Ethereum identity created."

# ============================================================
#  STEP 6: Link Human Identity with Agent
# ============================================================
print_step "6/6" "Linking Human Identity with your Agent"

echo ""
print_info "Using Agent Name: ${AGENT_NAME}"
print_info "Using Agent Description: ${AGENT_DESC}"
echo ""

node scripts/manualLinkHumanToAgent.js --challenge "{\"name\":\"${AGENT_NAME}\",\"description\":\"${AGENT_DESC}\"}"

# ============================================================
#  DONE
# ============================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║   ${BOLD}✔ Installation Complete!${NC}${GREEN}                                ║${NC}"
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
