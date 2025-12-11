# Source cargo environment if it exists (only after rustup/cargo installed)
test -f "$HOME/.cargo/env.fish"; and source "$HOME/.cargo/env.fish"
