#!/bin/bash

echo "🚀 Starting M365 Agent Services..."

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if agent directory exists
if [ -d "/workspaces/m365-test/agents/myagent" ]; then
    print_step "Checking M365 Agent status..."
    cd /workspaces/m365-test/agents/myagent
    
    # Verify package.json and dependencies
    if [ -f "package.json" ]; then
        print_success "M365 Agent ready"
    else
        echo "⚠️ Package.json not found, agent may need reinitialization"
    fi
else
    echo "⚠️ M365 Agent directory not found"
fi

# Display helpful information
echo ""
echo "🎯 M365 Agent Toolkit Ready!"
echo "============================"
echo "📁 Workspace: /workspaces/m365-test"
echo "🤖 Agent: /workspaces/m365-test/agents/myagent"
echo ""
echo "Quick Commands:"
echo "  atk-status  - Check environment"
echo "  atk-auth    - Test authentication"
echo "  atk-agent   - Navigate to agent"
echo ""
print_success "Services startup completed"