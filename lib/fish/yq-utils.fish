#!/usr/bin/env fish
# yq utilities for Fedpunk
# Provides safe yq execution that prevents environment pollution

function _yq_safe
    # Run yq with clean environment to avoid shell pollution
    # (e.g., kiwi_* vars in Fedora containers that echo to stdout)
    #
    # Usage: _yq_safe <yq-args...>
    # Example: _yq_safe '.profile' "$config_file"
    #
    # This is critical for Fedora container images built with kiwi,
    # which set environment variables like kiwi_align, kiwi_bootloader, etc.
    # that echo their values to stdout during shell initialization.

    env -i PATH="$PATH" HOME="$HOME" yq $argv
end

function _yq_safe_eval
    # Run yq eval with clean environment
    # Some yq calls use 'yq eval' explicitly
    #
    # Usage: _yq_safe_eval <expression> <file>
    # Example: _yq_safe_eval '.modules | length' "$yaml_file"

    env -i PATH="$PATH" HOME="$HOME" yq eval $argv
end
