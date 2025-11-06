# Claude Code Integration for Fish Shell
# Enhanced productivity features for Fedpunk developers

# Enhanced claude function with context awareness
function claude --wraps='command claude'
    # If in a git repository, add context
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set git_context "--context=git"
    else
        set git_context ""
    end
    
    # If we have arguments, pass them through
    if test (count $argv) -gt 0
        command claude $git_context $argv
    else
        # Interactive mode with project context
        command claude $git_context --interactive
    end
end

# Quick AI assistance functions
function ai_explain --description "Explain the last command or a file"
    if test (count $argv) -eq 0
        # Explain the last command
        set last_cmd (history | head -n 1)
        claude ask "Explain this command: $last_cmd"
    else
        # Explain a file or concept
        claude explain $argv
    end
end

function ai_fix --description "Fix issues in current directory or specific file"
    if test (count $argv) -eq 0
        # Fix issues in current directory
        claude fix .
    else
        claude fix $argv
    end
end

function ai_commit --description "Generate a git commit message"
    if git diff --cached --quiet
        echo "No staged changes found. Stage some changes first with 'git add'"
        return 1
    end
    
    echo "Generating commit message for staged changes..."
    set commit_msg (git diff --cached | claude ask "Generate a concise git commit message for these changes" --no-stream)
    echo "Suggested commit message:"
    echo "  $commit_msg"
    echo ""
    read -P "Use this commit message? [y/N]: " confirm
    
    if test "$confirm" = "y" -o "$confirm" = "Y"
        git commit -m "$commit_msg"
        echo "✅ Committed with AI-generated message"
    else
        echo "Commit cancelled"
    end
end

function ai_review --description "Review code changes"
    if test (count $argv) -eq 0
        # Review uncommitted changes
        if not git diff --quiet
            git diff | claude ask "Review this code diff and suggest improvements"
        else
            echo "No uncommitted changes to review"
        end
    else
        claude review $argv
    end
end

# Project-aware AI assistance
function ai_project --description "Ask about the current project"
    set project_files (find . -name "*.md" -o -name "package.json" -o -name "Cargo.toml" -o -name "pyproject.toml" | head -5)
    set context_info ""
    
    for file in $project_files
        set context_info "$context_info\n\nFile: $file\n"(head -20 $file)
    end
    
    claude ask "Based on this project context: $context_info\n\nQuestion: $argv"
end

# Development workflow integration
function ai_debug --description "Help debug an error"
    if test (count $argv) -eq 0
        echo "Usage: ai_debug <error_message_or_file>"
        echo "Example: ai_debug 'segmentation fault'"
        echo "Example: ai_debug error.log"
        return 1
    end
    
    if test -f $argv[1]
        # Debug from file
        claude ask "Help me debug this error log: "(cat $argv[1])
    else
        # Debug from command line
        claude ask "Help me debug this error: $argv"
    end
end

function ai_optimize --description "Suggest optimizations for code"
    if test (count $argv) -eq 0
        echo "Usage: ai_optimize <file_or_directory>"
        return 1
    end
    
    claude ask "Analyze this code and suggest performance optimizations: "(cat $argv[1])
end

# Fish-specific Claude Code shortcuts
function cc --wraps=claude
    claude $argv
end

function ask --wraps='claude ask'
    claude ask $argv
end

function fix --wraps='claude fix'
    claude fix $argv
end

function explain --wraps='claude explain'
    claude explain $argv
end

# Auto-completion for common development files
function __claude_complete_files
    # Complete with common development files
    find . -maxdepth 2 -name "*.fish" -o -name "*.py" -o -name "*.js" -o -name "*.rs" -o -name "*.go" -o -name "*.md" 2>/dev/null
end

# Set up completions for our custom functions
complete -c ai_explain -a "(__claude_complete_files)"
complete -c ai_fix -a "(__claude_complete_files)"
complete -c ai_review -a "(__claude_complete_files)"
complete -c ai_optimize -a "(__claude_complete_files)"

# Startup message for Claude Code
function __claude_startup_message --on-event fish_prompt
    # Only show once per session
    if not set -q __claude_message_shown
        if command -v claude >/dev/null 2>&1
            echo "🤖 Claude Code is ready! Try: cc ask 'your question' or ai_commit"
            set -g __claude_message_shown 1
        end
    end
end