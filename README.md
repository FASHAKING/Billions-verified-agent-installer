# Verified Agent Identity — Setup Guide

Choose your platform below and run the one-command installer.

---

## Termux (Android)

Open **Termux** on your Android phone and paste:

```bash
curl -sL https://raw.githubusercontent.com/FASHAKING/Billions-verified-agent-installer/main/install-agent.sh | bash
```

---

## Windows (PowerShell / Windows Terminal)

Open **PowerShell** or **Windows Terminal** and paste:

```powershell
irm https://raw.githubusercontent.com/FASHAKING/Billions-verified-agent-installer/main/install-agent-windows.ps1 | iex
```

> **Requirements:** Windows 10/11 with PowerShell 5.1+. The script will auto-install Node.js and Git via `winget` if they are missing.

---

## GitHub Codespaces / Workspaces / Gitpod / WSL

Open a terminal in your **Codespace**, **Workspace**, **Gitpod**, or **WSL** and paste:

```bash
curl -sL https://raw.githubusercontent.com/FASHAKING/Billions-verified-agent-installer/main/install-agent-codespaces.sh | bash
```

> Works on any Ubuntu/Debian-based Linux environment. Also supports Fedora, CentOS, and Alpine.

---

## What the installers do

Each installer follows the same steps:

1. Installs **Node.js** and **Git** (if not already present)
2. Clones the [verified-agent-identity](https://github.com/BillionsNetwork/verified-agent-identity) repository
3. Installs all dependencies via `clawhub` (plus common missing modules)
4. Creates your **Agent Ethereum Identity**
5. Links your **Human Identity** with your Agent
6. Gives you a **verification URL** to complete in your browser

---

## Manual Step-by-Step (Termux)

<details>
<summary>Click to expand manual Termux instructions</summary>

### Step 1 — Update Termux
```bash
pkg update && pkg upgrade
```

### Step 2 — Install Node.js and Git
```bash
pkg install nodejs
pkg install git
```
Verify with `node -v` — you should see something like `v25.x.x`.

### Step 3 — Clone the Repository
```bash
git clone https://github.com/BillionsNetwork/verified-agent-identity
cd verified-agent-identity
```

### Step 4 — Install Dependencies
```bash
npx clawhub@latest install verified-agent-identity
```
> Type `y` and press Enter whenever prompted.

### Step 5 — Create Agent Ethereum Identity
```bash
node scripts/createNewEthereumIdentity.js
```

### Step 6 — Link Human Identity with Agent
```bash
node scripts/manualLinkHumanToAgent.js --challenge '{"name":"YourAgentName","description":"AI agent"}'
```
Replace `YourAgentName` with your desired agent name.

After running this, you'll get a **verification URL** in the terminal.
Copy it → open in browser → connect wallet → verify. Done!

</details>

---

## Manual Step-by-Step (Windows)

<details>
<summary>Click to expand manual Windows instructions</summary>

### Step 1 — Install Node.js
Download and install from [nodejs.org](https://nodejs.org) or run:
```powershell
winget install OpenJS.NodeJS.LTS
```

### Step 2 — Install Git
Download and install from [git-scm.com](https://git-scm.com) or run:
```powershell
winget install Git.Git
```

### Step 3 — Clone the Repository
```powershell
git clone https://github.com/BillionsNetwork/verified-agent-identity
cd verified-agent-identity
```

### Step 4 — Install Dependencies
```powershell
npx clawhub@latest install verified-agent-identity
```

### Step 5 — Install Common Missing Modules
```powershell
npm install shell-quote @iden3/js-iden3-auth ethers@6 uuid
```

### Step 6 — Create Agent Ethereum Identity
```powershell
node scripts/createNewEthereumIdentity.js
```

### Step 7 — Link Human Identity with Agent
```powershell
node scripts/manualLinkHumanToAgent.js --challenge '{"name":"YourAgentName","description":"AI agent"}'
```

</details>

---

## Common Error Fixes

### Error: Cannot find module 'shell-quote'
```bash
npm install shell-quote
```

### Error: Cannot find module '@iden3/js-iden3-auth'
```bash
npm install @iden3/js-iden3-auth
```

> **Note:** The one-command installers pre-install these modules automatically.

---

## Need Help?

If you get stuck, feel free to open an issue or ask in the community.
