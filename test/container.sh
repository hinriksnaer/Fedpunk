#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Cleaning old builds..."
rm -rf /tmp/fedpunk-test /tmp/unstable.tar.gz

echo "==> Creating tarball from source..."
tar -czf /tmp/unstable.tar.gz -C "$(dirname "$REPO_DIR")" --transform "s|^$(basename "$REPO_DIR")|Fedpunk-unstable|" "$(basename "$REPO_DIR")"

echo "==> Building RPM..."
rpmbuild -bb fedpunk.spec --define "_sourcedir /tmp" --define "_rpmdir /tmp/fedpunk-test"

echo "==> Launching container..."
podman run -it --rm -v "/tmp/fedpunk-test:/rpms:z" fedora:latest bash -c '
    dnf install -y /rpms/noarch/fedpunk-*.rpm fish sudo >/dev/null 2>&1
    useradd -m -s /usr/bin/fish dev
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo ""
    echo "Fedpunk installed. Try: fedpunk module list"
    echo ""
    exec su - dev
'
