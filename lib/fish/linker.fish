#!/usr/bin/env fish
# Fedpunk Configuration Linker
# Replaces GNU Stow with state-tracked symlink management

# State file location
set -g LINKER_STATE_FILE "$FEDPUNK_ROOT/.linker-state.json"

# Initialize state file if it doesn't exist
function linker-init
    if not test -f "$LINKER_STATE_FILE"
        echo '{
  "version": "1.0",
  "files": {},
  "conflicts": {}
}' > "$LINKER_STATE_FILE"
    end
end

# Add file to state
function linker-state-add
    set -l target $argv[1]
    set -l source $argv[2]
    set -l module $argv[3]
    set -l timestamp (date -u +"%Y-%m-%dT%H:%M:%SZ")

    linker-init

    # Use jq to update state
    set -l temp_file (mktemp)
    jq --arg target "$target" \
       --arg source "$source" \
       --arg module "$module" \
       --arg timestamp "$timestamp" \
       '.files[$target] = {
           "source": $source,
           "module": $module,
           "deployed_at": $timestamp
       }' "$LINKER_STATE_FILE" > "$temp_file"
    and mv "$temp_file" "$LINKER_STATE_FILE"
end

# Remove file from state
function linker-state-remove
    set -l target $argv[1]

    if not test -f "$LINKER_STATE_FILE"
        return 0
    end

    set -l temp_file (mktemp)
    jq --arg target "$target" \
       'del(.files[$target])' "$LINKER_STATE_FILE" > "$temp_file"
    and mv "$temp_file" "$LINKER_STATE_FILE"
end

# Add conflict to state
function linker-state-add-conflict
    set -l target $argv[1]
    set -l module $argv[2]
    set -l action $argv[3]
    set -l timestamp (date -u +"%Y-%m-%dT%H:%M:%SZ")

    linker-init

    set -l temp_file (mktemp)
    jq --arg target "$target" \
       --arg module "$module" \
       --arg action "$action" \
       --arg timestamp "$timestamp" \
       '.conflicts[$target] = {
           "module": $module,
           "action": $action,
           "timestamp": $timestamp
       }' "$LINKER_STATE_FILE" > "$temp_file"
    and mv "$temp_file" "$LINKER_STATE_FILE"
end

# Get owner module of a file
function linker-get-owner
    set -l target $argv[1]

    if not test -f "$LINKER_STATE_FILE"
        return 1
    end

    jq -r --arg target "$target" \
       '.files[$target].module // empty' "$LINKER_STATE_FILE"
end

# Handle conflict interactively
function linker-handle-conflict
    set -l target $argv[1]
    set -l source $argv[2]
    set -l module $argv[3]
    set -l rel_path (string replace "$HOME/" "" "$target")

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  CONFLICT DETECTED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "File: $rel_path"
    echo "Module: $module"
    echo ""

    # Check if it's owned by another module
    if test -L "$target"
        set -l current_target (readlink -f "$target" 2>/dev/null; or echo "")
        set -l owner (linker-get-owner "$target")
        if test -n "$owner"
            echo "Currently owned by module: $owner"
        end
    else
        echo "Existing file (not a symlink)"
    end

    echo ""
    echo "Options:"
    echo "  [k] Keep existing file (skip this module file)"
    echo "  [r] Replace with module file (backup existing)"
    echo "  [d] Show diff"
    echo "  [a] Abort deployment"
    echo ""

    while true
        read -P "Choose action [k/r/d/a]: " -n 1 choice
        echo ""

        switch "$choice"
            case k K
                echo "  → Keeping existing file"
                linker-state-add-conflict "$target" "$module" "skipped"
                return 0

            case r R
                # Backup existing to centralized location
                set -l backup_dir "$HOME/.local/share/fedpunk-backups/config-backups"
                mkdir -p "$backup_dir"

                set -l backup_name (string replace -a "/" "_" (string replace "$HOME/" "" "$target"))
                set -l backup "$backup_dir/$backup_name.backup."(date +%Y%m%d-%H%M%S)

                if test -L "$target"
                    # Remove old symlink
                    rm "$target"
                else
                    # Backup regular file
                    mv "$target" "$backup"
                    echo "  → Backed up to: "(string replace "$HOME/" "~/" "$backup")
                end

                # Create new symlink
                ln -s "$source" "$target"
                echo "  → Replaced with module file"
                linker-state-add "$target" "$source" "$module"
                return 0

            case d D
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

                # Check if we can actually read the target file
                set -l can_diff false
                set -l target_file "$target"

                if test -L "$target"
                    # Target is a symlink - resolve it
                    set target_file (readlink -f "$target" 2>/dev/null; or echo "")
                    if test -n "$target_file" -a -f "$target_file"
                        set can_diff true
                    else
                        echo "Cannot diff: existing file is a broken symlink"
                        echo "Symlink points to: "(readlink "$target" 2>/dev/null; or echo "unknown")
                    end
                else if test -f "$target"
                    set can_diff true
                end

                if test "$can_diff" = "true" -a -f "$source"
                    diff -u "$target_file" "$source" | head -50; or true
                else if not test -f "$source"
                    echo "Cannot diff: module source file doesn't exist"
                end

                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                # Ask again
                continue

            case a A
                echo "  → Aborting deployment"
                return 1

            case '*'
                echo "Invalid choice, try again"
                continue
        end
    end
end

# Deploy module configuration
function linker-deploy
    set -l module_name $argv[1]
    set -l module_dir $argv[2]
    set -l config_dir "$module_dir/config"

    if not test -d "$config_dir"
        echo "  → No config directory, skipping symlinks"
        return 0
    end

    echo "  → Deploying configuration files"
    linker-init

    # Find all files in config directory
    set -l file_count 0
    set -l skipped_count 0

    for src_file in (find "$config_dir" -type f)
        # Calculate relative path (remove config_dir prefix)
        set -l rel_path (string replace "$config_dir/" "" "$src_file")
        set -l target "$HOME/$rel_path"

        # Check for conflicts
        if test -e "$target"; and not test -L "$target"
            # File exists and is NOT a symlink
            if not linker-handle-conflict "$target" "$src_file" "$module_name"
                return 1
            end
            set skipped_count (math $skipped_count + 1)
            continue
        end

        if test -L "$target"
            # Symlink exists - check if it's ours
            set -l current_target (readlink -f "$target" 2>/dev/null; or echo "")
            set -l expected_target (readlink -f "$src_file")

            if test "$current_target" != "$expected_target"
                # Owned by different module
                if not linker-handle-conflict "$target" "$src_file" "$module_name"
                    return 1
                end
                set skipped_count (math $skipped_count + 1)
                continue
            else
                # Already correctly linked
                set file_count (math $file_count + 1)
                continue
            end
        end

        # Create parent directory
        mkdir -p (dirname "$target")

        # Create symlink
        ln -s "$src_file" "$target"
        linker-state-add "$target" "$src_file" "$module_name"
        set file_count (math $file_count + 1)
    end

    if test $file_count -gt 0
        echo "  ✓ Linked $file_count files"
    end
    if test $skipped_count -gt 0
        echo "  ⚠️  Skipped $skipped_count conflicts"
    end
end

# Remove module configuration
function linker-remove
    set -l module_name $argv[1]

    if not test -f "$LINKER_STATE_FILE"
        echo "  → No deployment state found"
        return 0
    end

    echo "  → Removing configuration files"

    # Get all files owned by this module
    set -l files (jq -r --arg module "$module_name" \
        '.files | to_entries[] | select(.value.module == $module) | .key' \
        "$LINKER_STATE_FILE")

    if test -z "$files"
        echo "  → No files deployed by this module"
        return 0
    end

    set -l count 0
    for target in $files
        if test -L "$target"
            rm "$target"
            linker-state-remove "$target"
            set count (math $count + 1)
        else if test -e "$target"
            echo "  ⚠️  Not a symlink (manual intervention needed): "(string replace "$HOME/" "" "$target")
        end
    end

    if test $count -gt 0
        echo "  ✓ Removed $count files"
    end
end

# Show deployment status
function linker-status
    if not test -f "$LINKER_STATE_FILE"
        echo "No modules deployed"
        return 0
    end

    echo "Deployed Configuration:"
    echo ""

    # Group by module
    jq -r '.files | to_entries | group_by(.value.module)[] |
           "\(.[0].value.module): \(length) files"' \
        "$LINKER_STATE_FILE" | sort

    # Show conflicts if any
    set -l conflict_count (jq '.conflicts | length' "$LINKER_STATE_FILE")
    if test $conflict_count -gt 0
        echo ""
        echo "Conflicts:"
        jq -r '.conflicts | to_entries[] |
               "  \(.key) → \(.value.action) (module: \(.value.module))"' \
            "$LINKER_STATE_FILE"
    end
end

# Show files owned by a module
function linker-list-files
    set -l module_name $argv[1]

    if not test -f "$LINKER_STATE_FILE"
        echo "No modules deployed"
        return 0
    end

    set -l files (jq -r --arg module "$module_name" \
        '.files | to_entries[] | select(.value.module == $module) | .key' \
        "$LINKER_STATE_FILE")

    if test -z "$files"
        echo "No files deployed by module: $module_name"
        return 0
    end

    echo "Files deployed by $module_name:"
    for target in $files
        echo "  "(string replace "$HOME/" "" "$target")
    end
end

# Deploy module CLI commands
# Deploys module/cli/ or plugin/cli/ to $FEDPUNK_ROOT/cli/
function linker-deploy-cli
    set -l module_name $argv[1]
    set -l module_dir $argv[2]
    set -l cli_dir "$module_dir/cli"

    if not test -d "$cli_dir"
        return 0  # No CLI to deploy, not an error
    end

    echo "  → Deploying CLI commands"
    linker-init

    set -l file_count 0
    set -l dir_count 0

    # Find all command directories and files
    for src_item in $cli_dir/*/
        if not test -d "$src_item"
            continue
        end

        set -l cmd_name (basename "$src_item")
        set -l target_dir "$FEDPUNK_ROOT/cli/$cmd_name"

        # Check for command directory conflict
        if test -d "$target_dir"; and not test -L "$target_dir"
            # Directory exists and is not a symlink - check owner
            set -l owner (linker-get-owner "$target_dir")
            if test -n "$owner"; and test "$owner" != "$module_name"
                echo "  ⚠️  CLI conflict: $cmd_name (owned by $owner)"
                continue
            end
            # No owner or same owner - remove directory to replace with symlink
            if test -z "$(ls -A "$target_dir" 2>/dev/null)"
                # Empty directory - safe to remove
                rmdir "$target_dir" 2>/dev/null
            else
                echo "  ⚠️  CLI conflict: $cmd_name has files (manual cleanup needed)"
                continue
            end
        end

        # Symlink the entire command directory
        if test -L "$target_dir"
            # Already a symlink - check if pointing to right place
            set -l current (readlink -f "$target_dir" 2>/dev/null; or echo "")
            set -l expected (readlink -f "$src_item" 2>/dev/null; or echo "")
            if test "$current" = "$expected"
                set dir_count (math $dir_count + 1)
                continue
            else
                # Different target - remove old symlink
                rm "$target_dir"
            end
        end

        # Create symlink to command directory
        mkdir -p (dirname "$target_dir")
        ln -s "$src_item" "$target_dir"
        linker-state-add "$target_dir" "$src_item" "$module_name"
        set dir_count (math $dir_count + 1)
    end

    if test $dir_count -gt 0
        echo "  ✓ Linked $dir_count CLI command(s)"
    end
end

# Remove module CLI commands
function linker-remove-cli
    set -l module_name $argv[1]

    if not test -f "$LINKER_STATE_FILE"
        return 0
    end

    # Get all CLI directories owned by this module
    set -l cli_dirs (jq -r --arg module "$module_name" \
        --arg prefix "$FEDPUNK_ROOT/cli/" \
        '.files | to_entries[] | select(.value.module == $module) | select(.key | startswith($prefix)) | .key' \
        "$LINKER_STATE_FILE")

    if test -z "$cli_dirs"
        return 0
    end

    echo "  → Removing CLI commands"

    set -l count 0
    for target in $cli_dirs
        if test -L "$target"
            rm "$target"
            linker-state-remove "$target"
            set count (math $count + 1)
        else if test -e "$target"
            echo "  ⚠️  Not a symlink: "(string replace "$FEDPUNK_ROOT/" "" "$target")
        end
    end

    if test $count -gt 0
        echo "  ✓ Removed $count CLI command(s)"
    end
end
