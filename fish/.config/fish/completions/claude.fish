# Claude Code completions for Fish shell
complete -c claude -f

# Basic commands
complete -c claude -n "__fish_use_subcommand" -a "ask" -d "Ask Claude a question"
complete -c claude -n "__fish_use_subcommand" -a "code" -d "Generate or edit code"
complete -c claude -n "__fish_use_subcommand" -a "fix" -d "Fix code issues"
complete -c claude -n "__fish_use_subcommand" -a "explain" -d "Explain code"
complete -c claude -n "__fish_use_subcommand" -a "review" -d "Review code"
complete -c claude -n "__fish_use_subcommand" -a "test" -d "Generate tests"
complete -c claude -n "__fish_use_subcommand" -a "refactor" -d "Refactor code"

# Global options
complete -c claude -s h -l help -d "Show help"
complete -c claude -s v -l version -d "Show version"
complete -c claude -l config -d "Configuration file path"
complete -c claude -l interactive -d "Start interactive mode"
