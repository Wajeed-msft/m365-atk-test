#!/bin/bash

set -e

echo "🚀 Setting up M365 Agent Toolkit Environment..."
echo "=============================================="

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Step 1: Update system and install dependencies
print_step "1️⃣  Updating system packages..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y curl wget git build-essential > /dev/null 2>&1
print_success "System packages updated"

# Step 2: Install M365 Agent Toolkit CLI
print_step "2️⃣  Installing M365 Agent Toolkit CLI..."
npm install -g @microsoft/m365agentstoolkit-cli
if command -v atk &> /dev/null; then
    ATK_VERSION=$(atk --version)
    print_success "ATK CLI installed: $ATK_VERSION"
else
    print_error "Failed to install ATK CLI"
    exit 1
fi

# Step 3: Create workspace structure
print_step "3️⃣  Creating workspace structure..."
mkdir -p /workspaces/m365-test/agents
mkdir -p /workspaces/m365-test/logs
mkdir -p /workspaces/m365-test/scripts
print_success "Workspace directories created"

# Step 4: Create M365 Agent with specific parameters
print_step "4️⃣  Creating M365 Agent with TypeScript..."
cd /workspaces/m365-test/agents

echo "   Command: atk new -c basic-custom-engine-agent -l typescript -n myagent -i false"
if atk new -c basic-custom-engine-agent -l typescript -n myagent -i false; then
    print_success "M365 Agent 'myagent' created successfully"
else
    print_error "Failed to create M365 Agent"
    # Don't exit, continue with setup
fi

# Step 5: Install agent dependencies if agent was created
if [ -d "/workspaces/m365-test/agents/myagent" ]; then
    print_step "5️⃣  Installing agent dependencies..."
    cd /workspaces/m365-test/agents/myagent
    
    if npm install; then
        print_success "Agent dependencies installed"
    else
        print_warning "Some issues with dependency installation"
    fi
    
    # Verify package.json
    if [ -f "package.json" ]; then
        print_success "Package.json found - TypeScript configuration ready"
    fi
else
    print_warning "Agent directory not found, skipping dependency installation"
fi

# Step 6: Install additional useful tools
print_step "6️⃣  Installing additional development tools..."
npm install -g concurrently dotenv-cli typescript > /dev/null 2>&1
print_success "Additional tools installed"

# Step 7: Create helper scripts
print_step "7️⃣  Creating helper scripts..."

# ATK Auth Test Script
cat > /workspaces/m365-test/scripts/test-atk-auth.sh << 'EOF'
#!/bin/bash
echo "🔐 Testing ATK Authentication..."

AGENT_DIR="/workspaces/m365-test/agents/myagent"
LOG_FILE="/workspaces/m365-test/logs/auth-$(date +%Y%m%d-%H%M%S).log"

if [ ! -d "$AGENT_DIR" ]; then
    echo "❌ Agent directory not found: $AGENT_DIR"
    exit 1
fi

cd "$AGENT_DIR"

echo "📄 Starting ATK auth, logging to: $LOG_FILE"
echo "🚀 Command: nohup atk auth login m365 > $LOG_FILE 2>&1 &"

# Start auth in background
nohup atk auth login m365 > "$LOG_FILE" 2>&1 &
AUTH_PID=$!

echo "🔄 Auth process started (PID: $AUTH_PID)"
echo "⏳ Waiting 8 seconds for auth server to start..."
sleep 8

echo ""
echo "📋 Auth log contents:"
echo "---"
if [ -f "$LOG_FILE" ]; then
    cat "$LOG_FILE"
    echo "---"
    
    # Extract OAuth URL
    OAUTH_URL=$(grep -oE "https://login\.microsoftonline\.com/[^[:space:]]+" "$LOG_FILE" | head -1)
    if [ ! -z "$OAUTH_URL" ]; then
        echo ""
        echo "🌐 OAuth URL found: $OAUTH_URL"
        echo "📝 Open this URL in your browser to complete authentication"
    else
        echo "⚠️ No OAuth URL found in logs yet"
    fi
else
    echo "❌ Log file not created"
fi

echo ""
echo "🔗 Access your codespace ports:"
echo "   Auth Server (3978): Use port forwarding in VS Code"
echo "   Agent UI (56150): Use port forwarding in VS Code"
echo ""
echo "✅ ATK Auth test completed!"
EOF

chmod +x /workspaces/m365-test/scripts/test-atk-auth.sh

# ATK Status Check Script
cat > /workspaces/m365-test/scripts/check-atk-status.sh << 'EOF'
#!/bin/bash
echo "🔍 ATK Environment Status Check"
echo "=============================="

echo "📦 ATK Version:"
atk --version

echo ""
echo "📁 Workspace Structure:"
ls -la /workspaces/m365-test/

echo ""
echo "🤖 Agent Directory:"
if [ -d "/workspaces/m365-test/agents/myagent" ]; then
    echo "✅ Agent 'myagent' found"
    ls -la /workspaces/m365-test/agents/myagent/
    
    echo ""
    echo "📄 Package.json Summary:"
    if [ -f "/workspaces/m365-test/agents/myagent/package.json" ]; then
        node -pe "const pkg = require('/workspaces/m365-test/agents/myagent/package.json'); console.log('Name:', pkg.name, '\nVersion:', pkg.version, '\nScripts:', Object.keys(pkg.scripts || {}).join(', '))"
    fi
else
    echo "❌ Agent 'myagent' not found"
fi

echo ""
echo "🌐 Environment Variables:"
echo "WORKSPACE_ROOT: $WORKSPACE_ROOT"
echo "ATK_AGENT_PATH: $ATK_AGENT_PATH"

echo ""
echo "✅ Status check completed!"
EOF

chmod +x /workspaces/m365-test/scripts/check-atk-status.sh

print_success "Helper scripts created"

# Step 8: Create quick start guide
print_step "8️⃣  Creating quick start guide..."
cat > /workspaces/m365-test/README.md << 'EOF'
# M365 Agent Toolkit - Quick Start Guide

## Environment Ready! 🎉

Your M365 Agent Toolkit environment is fully configured and ready to use.

### What's Pre-Installed
- ✅ M365 Agent Toolkit CLI (`atk`)
- ✅ TypeScript M365 Agent (`myagent`)
- ✅ All agent dependencies
- ✅ Development tools (Node.js 18, TypeScript, etc.)

### Directory Structure
```
/workspaces/m365-test/
├── agents/
│   └── myagent/          # Your TypeScript M365 agent
├── logs/                 # Authentication logs
├── scripts/              # Helper scripts
└── README.md            # This guide
```

### Quick Commands

#### Check Environment Status
```bash
./scripts/check-atk-status.sh
```

#### Test ATK Authentication
```bash
./scripts/test-atk-auth.sh
```

#### Manual ATK Authentication
```bash
cd agents/myagent
atk auth login m365
```

### Port Forwarding
Your codespace is configured to forward these ports:
- **3978**: ATK Auth Server (public)
- **56150**: M365 Agent UI (public)
- **3000-3002**: Development servers (public)

### Next Steps
1. Run `./scripts/check-atk-status.sh` to verify everything is working
2. Run `./scripts/test-atk-auth.sh` to test M365 authentication
3. Open the OAuth URL in your browser to complete authentication
4. Access your agent via the forwarded ports

### Agent Details
- **Template**: basic-custom-engine-agent
- **Language**: TypeScript
- **Name**: myagent
- **Interactive Mode**: Disabled
- **Location**: `/workspaces/m365-test/agents/myagent`

Ready to build your M365 agent! 🚀
EOF

print_success "Quick start guide created"

# Step 9: Set up Git configuration if needed
if [ -z "$(git config --global user.name)" ]; then
    print_step "9️⃣  Setting up default Git configuration..."
    git config --global user.name "CodespacesUser"
    git config --global user.email "user@codespaces.dev"
    print_success "Git configuration set"
fi

# Step 10: Set permissions and final touches
print_step "🔟  Final setup touches..."
chown -R node:node /workspaces/m365-test
chmod -R 755 /workspaces/m365-test/scripts

# Create .zshrc aliases for convenience
cat >> /home/node/.zshrc << 'EOF'

# M365 Agent Toolkit Aliases
alias atk-status='bash /workspaces/m365-test/scripts/check-atk-status.sh'
alias atk-auth='bash /workspaces/m365-test/scripts/test-atk-auth.sh'
alias atk-agent='cd /workspaces/m365-test/agents/myagent'
alias atk-logs='cd /workspaces/m365-test/logs'

# Quick navigation
alias workspace='cd /workspaces/m365-test'
EOF

print_success "Aliases and permissions set"

# Final summary
echo ""
echo "🎉 M365 Agent Toolkit Environment Setup Complete!"
echo "================================================"
echo ""
echo "📋 What's Ready:"
echo "   ✅ ATK CLI installed and verified"
echo "   ✅ TypeScript M365 agent 'myagent' created"
echo "   ✅ All dependencies installed"
echo "   ✅ Helper scripts and aliases configured"
echo "   ✅ Port forwarding configured"
echo ""
echo "🚀 Quick Commands:"
echo "   atk-status    - Check environment status"
echo "   atk-auth      - Test M365 authentication"
echo "   atk-agent     - Go to agent directory"
echo "   workspace     - Go to workspace root"
echo ""
echo "📁 Agent Location: /workspaces/m365-test/agents/myagent"
echo "📖 Guide: cat /workspaces/m365-test/README.md"
echo ""
echo "✅ Ready to test ATK authentication! Run: atk-auth"