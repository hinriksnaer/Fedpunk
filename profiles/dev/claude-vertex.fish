#!/usr/bin/env fish
# Claude Code - Google Vertex AI Authentication
# This file configures Claude Code to use Google Vertex AI instead of standard API key auth
#
# To enable: Uncomment the source line in config.fish
# To disable: Comment out the source line in config.fish

# Enable Vertex AI for Claude Code
set -gx CLAUDE_CODE_USE_VERTEX 1

# Google Cloud region for Vertex AI
set -gx CLOUD_ML_REGION us-east5

# Google Cloud project ID for Anthropic Vertex AI
set -gx ANTHROPIC_VERTEX_PROJECT_ID itpc-gcp-ai-eng-claude
