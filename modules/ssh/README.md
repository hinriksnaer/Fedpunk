# SSH Module

Provides opinionated SSH client configuration with good defaults for development.

## Features

- **Connection multiplexing** - Reuse SSH connections for faster git/ansible operations
- **Auto key management** - Automatically adds keys to ssh-agent when used
- **Keepalive** - Prevents connection timeouts on idle sessions
- **Privacy** - Hashes hostnames in known_hosts file
- **Separation of concerns** - Module manages defaults, you manage hosts

## File Structure

```
~/.ssh/
├── config              # Managed by module (defaults)
├── config.d/
│   └── hosts           # Your personal hosts (NOT managed)
├── sockets/            # Connection multiplexing (auto-created)
├── id_*                # Your SSH keys
└── known_hosts         # Trusted host keys
```

## Usage

### Adding Your Hosts

Edit `~/.ssh/config.d/hosts` to add your servers:

```ssh
Host myserver
    HostName example.com
    User myusername
    ForwardAgent yes

Host github
    HostName github.com
    User git
```

### Backup Your Configuration

```bash
# Backup keys AND hosts configuration
fedpunk vault ssh-backup

# List backups
fedpunk vault ssh-list

# Restore on new machine
fedpunk vault ssh-restore
fedpunk vault ssh-load
```

## What Gets Backed Up

When you run `fedpunk vault ssh-backup`, it backs up:
- ✅ SSH keys (`~/.ssh/id_*`)
- ✅ Personal hosts (`~/.ssh/config.d/hosts`)
- ❌ NOT the main config (managed by this module)

## Benefits

### Connection Multiplexing
Multiple SSH sessions to the same host share one connection:
- **Git operations** are much faster (no new handshake per command)
- **Ansible playbooks** run faster
- **Repeated connections** instant after first connection

### Auto Key Management
Keys are automatically added to ssh-agent when first used - no manual `ssh-add` needed.

### Keepalive
Connections won't timeout during idle periods (60s interval checks).

## Customization

The main `~/.ssh/config` is managed by this module. To customize:

1. **For host-specific settings** → Edit `~/.ssh/config.d/hosts`
2. **For global defaults** → Modify this module and rebuild

## Security Notes

- `ForwardAgent` is NOT enabled by default (security risk)
- Enable it per-host in `~/.ssh/config.d/hosts` only for trusted servers
- `HashKnownHosts` protects your server list privacy
