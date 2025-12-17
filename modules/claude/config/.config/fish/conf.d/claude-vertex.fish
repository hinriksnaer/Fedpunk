#!/usr/bin/env fish
# Claude Code - Google Vertex AI Authentication
# This configuration enables Claude Code to use Google Vertex AI instead of standard API key auth

# Enable Vertex AI for Claude Code
set -gx CLAUDE_CODE_USE_VERTEX 1

# Google Cloud region for Vertex AI
# Configurable via FEDPUNK_PARAM_CLAUDE_REGION parameter
if set -q FEDPUNK_PARAM_CLAUDE_REGION
    set -gx CLOUD_ML_REGION $FEDPUNK_PARAM_CLAUDE_REGION
else
    set -gx CLOUD_ML_REGION us-east5
end

# Google Cloud project ID for Anthropic Vertex AI
# Configurable via FEDPUNK_PARAM_CLAUDE_PROJECT_ID parameter
if set -q FEDPUNK_PARAM_CLAUDE_PROJECT_ID
    set -gx ANTHROPIC_VERTEX_PROJECT_ID $FEDPUNK_PARAM_CLAUDE_PROJECT_ID
else
    set -gx ANTHROPIC_VERTEX_PROJECT_ID itpc-gcp-ai-eng-claude
end
