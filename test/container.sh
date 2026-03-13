#!/bin/bash
set -e

echo "==> Cleaning old builds..."
rm -rf /tmp/fedpunk-test /tmp/unstable.tar.gz

echo "==> Creating tarball from git..."
git archive --format=tar.gz --prefix=Fedpunk-unstable/ -o /tmp/unstable.tar.gz HEAD

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
