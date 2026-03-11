#!/bin/bash
# Sidcom Architecture — one-line setup for any project
# Usage: curl -fsSL https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/setup.sh | bash

mkdir -p .claude
curl -fsSL -o .claude/settings.json https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/.claude/settings.json
echo "[sidcom-architecture] Setup hook installed. Start Claude Code to initialize."
