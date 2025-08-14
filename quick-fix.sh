#!/bin/bash

echo "🔧 Quick Fix: Installing missing packages and fixing ATK executor"

# Install xdg-utils (needed for browser launching)
echo "📦 Installing xdg-utils..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y xdg-utils

# Download fixed ATK executor
echo "📥 Downloading fixed ATK executor..."
curl -o atk-executor.mjs https://raw.githubusercontent.com/Wajeed-msft/m365-atk-test/main/atk-executor.mjs

# Make it executable
chmod +x atk-executor.mjs

echo "✅ Quick fix complete!"
echo ""
echo "🚀 Now you can run:"
echo "   node atk-executor.mjs"
echo ""
echo "📦 Packages installed:"
echo "   ✅ xdg-utils (for browser launching)"
echo ""
echo "🔧 Fixed files:"
echo "   ✅ atk-executor.mjs (proper ES module)"
