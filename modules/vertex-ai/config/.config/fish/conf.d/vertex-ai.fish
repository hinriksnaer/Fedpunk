#!/usr/bin/env fish
# Claude Code - Google Vertex AI Authentication
# This configuration enables Claude Code to use Google Vertex AI instead of standard API key auth

# Enable Vertex AI for Claude Code
set -gx CLAUDE_CODE_USE_VERTEX 1

# Google Cloud region for Vertex AI
set -gx CLOUD_ML_REGION us-east5

# Google Cloud project ID for Anthropic Vertex AI
set -gx ANTHROPIC_VERTEX_PROJECT_ID itpc-gcp-ai-eng-claude
