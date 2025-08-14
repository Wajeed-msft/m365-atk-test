#!/bin/bash
set -e
echo "🚀 Setting up M365 Agent Toolkit environment..."
npm install -g @microsoft/m365agentstoolkit-cli
mkdir -p /workspaces/m365-test/agents /workspaces/m365-test/logs
echo "✅ Environment ready for ATK testing!"
