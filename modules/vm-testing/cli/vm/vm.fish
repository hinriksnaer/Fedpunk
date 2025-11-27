# VM testing commands for Fedpunk development

set -g VM_DIR "$HOME/VMs"
set -g ISO_DIR "/tmp/fedpunk-iso"
set -g DEFAULT_VM "fedpunk-test"

function vm --description "VM testing environment"
    if contains -- "$argv[1]" --help -h
        printf "VM testing environment for Fedpunk development\n"
        printf "\n"
        printf "Create and manage test VMs for installation testing.\n"
        return 0
    end
    _show_command_help vm
end

function _vm_exists
    set -l vm_name $argv[1]
    virsh list --all 2>/dev/null | grep -q "$vm_name"
end

function _require_vm
    set -l vm_name $argv[1]
    if not _vm_exists "$vm_name"
        printf "Error: VM '%s' does not exist\n" "$vm_name" >&2
        return 1
    end
end

function _ensure_libvirt
    # Check if libvirt is installed
    if not command -v virsh >/dev/null 2>&1
        printf "Error: libvirt not installed\n" >&2
        printf "Run: fedpunk module deploy vm-testing\n" >&2
        return 1
    end

    # Check if service exists
    if not systemctl list-unit-files libvirtd.service >/dev/null 2>&1
        printf "Error: libvirtd service not found\n" >&2
        printf "Run: fedpunk module deploy vm-testing\n" >&2
        return 1
    end

    if not systemctl is-active --quiet libvirtd
        printf "Starting libvirtd service...\n"
        sudo systemctl start libvirtd
        or begin
            printf "Error: Failed to start libvirtd\n" >&2
            return 1
        end
    end
end

function _download_image
    set -l choice $argv[1]
    set -l dest_dir $argv[2]
    set -l url ""
    set -l filename ""

    switch $choice
        case "Fedora 43 Cloud (quick)"
            set url "https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
            set filename "Fedora-43-Cloud.qcow2"
        case "Fedora 42 Cloud (quick)"
            set url "https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-42-1.1.qcow2"
            set filename "Fedora-42-Cloud.qcow2"
        case '*'
            printf "Unknown image choice\n" >&2
            return 1
    end

    set -l image_path "$dest_dir/$filename"

    if test -f "$image_path"
        set -l size (stat -c%s "$image_path" 2>/dev/null || echo 0)
        if test $size -gt 100000000
            printf "Image already exists: %s\n" "$image_path" >&2
            echo "$image_path"
            return 0
        else
            rm -f "$image_path"
        end
    end

    printf "Downloading: %s\n" "$filename" >&2
    printf "This may take a few minutes...\n\n" >&2

    curl -L --progress-bar -o "$image_path" "$url"
    or begin
        printf "Error: Download failed\n" >&2
        rm -f "$image_path"
        return 1
    end

    echo "$image_path"
    return 0
end

function create --description "Create a new test VM"
    if contains -- "$argv[1]" --help -h
        printf "Create a new test VM\n"
        printf "\n"
        printf "Usage: fedpunk vm create [name]\n"
        printf "\n"
        printf "Uses Fedora Cloud images - boots instantly, no installation needed.\n"
        printf "Default login: root (no password) or use console\n"
        printf "\n"
        printf "Options (via environment):\n"
        printf "  VM_MEMORY=4096      Memory in MB (default: 4GB)\n"
        printf "  VM_CPUS=2           CPU cores (default: 2)\n"
        printf "  VM_DISK_SIZE=20     Disk in GB (default: 20GB)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk vm create\n"
        printf "  fedpunk vm create my-test-vm\n"
        return 0
    end

    _ensure_libvirt; or return 1

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    set -l vm_memory (test -n "$VM_MEMORY" && echo $VM_MEMORY || echo "4096")
    set -l vm_cpus (test -n "$VM_CPUS" && echo $VM_CPUS || echo "2")
    set -l vm_disk (test -n "$VM_DISK_SIZE" && echo $VM_DISK_SIZE || echo "20")

    set -l disk_path "$VM_DIR/$vm_name.qcow2"

    # Check virtualization support
    if not grep -qE '(vmx|svm)' /proc/cpuinfo
        printf "Error: Hardware virtualization not enabled\n" >&2
        printf "Enable VT-x (Intel) or AMD-V (AMD) in BIOS\n" >&2
        return 1
    end

    # Check if VM exists
    if _vm_exists "$vm_name"
        printf "Error: VM '%s' already exists\n" "$vm_name" >&2
        printf "Run: fedpunk vm destroy %s\n" "$vm_name" >&2
        return 1
    end

    # Create directories
    mkdir -p "$VM_DIR" "$ISO_DIR"

    # Image options
    set -l image_options
    set -a image_options "Fedora 43 Cloud (quick)"
    set -a image_options "Fedora 42 Cloud (quick)"

    printf "Select Fedora image:\n\n"

    set -l choice ""
    if command -v gum >/dev/null 2>&1
        set choice (printf "%s\n" $image_options | gum choose)
    else
        for i in (seq (count $image_options))
            printf "  %d) %s\n" $i $image_options[$i]
        end
        read -l -P "Select: " idx
        set choice $image_options[$idx]
    end

    if test -z "$choice"
        printf "Cancelled\n"
        return 1
    end

    # Download base image
    set -l base_image (_download_image "$choice" "$ISO_DIR")
    or return 1

    printf "\n"
    printf "Creating VM: %s\n" "$vm_name"
    printf "  Memory: %sGB\n" (math "$vm_memory / 1024")
    printf "  CPUs:   %s\n" "$vm_cpus"
    printf "  Disk:   %sGB\n" "$vm_disk"
    printf "\n"

    # Create disk from base image
    printf "Creating disk from cloud image...\n"
    cp "$base_image" "$disk_path"
    qemu-img resize "$disk_path" "$vm_disk"G 2>/dev/null

    # Get current branch for install script
    set -l branch (_get_current_branch)

    # Create cloud-init ISO for credentials
    set -l ci_dir (mktemp -d)
    set -l ci_iso "$VM_DIR/$vm_name-cidata.iso"

    # meta-data
    printf "instance-id: %s\nlocal-hostname: %s\n" "$vm_name" "$vm_name" > "$ci_dir/meta-data"

    # user-data - write directly to file to preserve YAML formatting
    echo "#cloud-config
users:
  - name: test
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_pwauth: true
disable_root: false
chpasswd:
  expire: false
  users:
    - name: root
      password: '1234'
      type: text
    - name: test
      password: '1234'
      type: text
write_files:
  - path: /root/install.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      # Install Fedpunk from branch: $branch
      curl -fsSL \"https://raw.githubusercontent.com/hinriksnaer/Fedpunk/$branch/boot.sh\" | FEDPUNK_REF=\"$branch\" bash
  - path: /home/test/install.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      # Install Fedpunk from branch: $branch
      curl -fsSL \"https://raw.githubusercontent.com/hinriksnaer/Fedpunk/$branch/boot.sh\" | FEDPUNK_REF=\"$branch\" bash
runcmd:
  - mkdir -p /home/test
  - chown -R test:test /home/test
  - chmod 755 /home/test
  - sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
  - sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
  - systemctl restart sshd || true
  - echo 'test:1234' | chpasswd
  - echo 'root:1234' | chpasswd
" > "$ci_dir/user-data"

    # Create ISO
    genisoimage -output "$ci_iso" -volid cidata -joliet -rock "$ci_dir/user-data" "$ci_dir/meta-data" 2>/dev/null
    or mkisofs -output "$ci_iso" -volid cidata -joliet -rock "$ci_dir/user-data" "$ci_dir/meta-data" 2>/dev/null
    rm -rf "$ci_dir"

    # Create VM
    printf "Creating VM...\n"
    virt-install \
        --name "$vm_name" \
        --memory "$vm_memory" \
        --vcpus "$vm_cpus" \
        --cpu host-passthrough \
        --disk path="$disk_path",format=qcow2,bus=virtio \
        --disk path="$ci_iso",device=cdrom \
        --import \
        --os-variant fedora-unknown \
        --network user,model=virtio \
        --graphics spice,listen=127.0.0.1 \
        --video virtio \
        --console pty,target_type=serial \
        --virt-type kvm \
        --noautoconsole

    if test $status -ne 0
        printf "Error: Failed to create VM\n" >&2
        rm -f "$disk_path"
        return 1
    end

    printf "\n"
    printf "✓ VM created and started!\n"
    printf "\n"
    printf "Login: test or root (password: 1234)\n"
    printf "\n"
    printf "Connect now:\n"
    printf "  fedpunk vm open %s       # GUI viewer\n" "$vm_name"
    printf "  fedpunk vm console %s    # Serial console\n" "$vm_name"
    printf "\n"
    printf "Install Fedpunk in VM:\n"
    printf "  ./install.sh             # Script already in VM (branch: %s)\n" "$branch"
    printf "\n"
    printf "After setup:\n"
    printf "  fedpunk vm snapshot %s fresh\n" "$vm_name"
end

function start --description "Start a VM"
    if contains -- "$argv[1]" --help -h
        printf "Start a VM\n"
        printf "\n"
        printf "Usage: fedpunk vm start [name]\n"
        return 0
    end

    _ensure_libvirt; or return 1
    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    printf "Starting %s...\n" "$vm_name"
    virsh start "$vm_name"
    printf "✓ VM started\n"
end

function stop --description "Stop a VM gracefully"
    if contains -- "$argv[1]" --help -h
        printf "Stop a VM gracefully\n"
        printf "\n"
        printf "Usage: fedpunk vm stop [name]\n"
        return 0
    end

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    printf "Stopping %s...\n" "$vm_name"
    virsh shutdown "$vm_name"
    printf "✓ Shutdown signal sent\n"
end

function kill --description "Force stop a VM"
    if contains -- "$argv[1]" --help -h
        printf "Force stop a VM immediately\n"
        printf "\n"
        printf "Usage: fedpunk vm kill [name]\n"
        return 0
    end

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    printf "Force stopping %s...\n" "$vm_name"
    virsh destroy "$vm_name"
    printf "✓ VM stopped\n"
end

function open --description "Open VM in GUI viewer"
    if contains -- "$argv[1]" --help -h
        printf "Open VM in virt-viewer GUI\n"
        printf "\n"
        printf "Usage: fedpunk vm open [name]\n"
        return 0
    end

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    if not command -v virt-viewer >/dev/null
        printf "Error: virt-viewer not installed\n" >&2
        printf "Run: fedpunk module deploy vm-testing\n" >&2
        return 1
    end

    printf "Opening %s...\n" "$vm_name"
    virt-viewer "$vm_name" &
    printf "✓ GUI viewer launched\n"
end

function console --description "Connect to VM serial console"
    if contains -- "$argv[1]" --help -h
        printf "Connect to VM serial console\n"
        printf "\n"
        printf "Usage: fedpunk vm console [name]\n"
        printf "\n"
        printf "Press Ctrl+] to exit\n"
        return 0
    end

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    printf "Connecting to %s (Ctrl+] to exit)...\n\n" "$vm_name"
    virsh console "$vm_name"
end

function snapshot --description "Create a VM snapshot"
    if contains -- "$argv[1]" --help -h
        printf "Create a VM snapshot\n"
        printf "\n"
        printf "Usage: fedpunk vm snapshot [name] <snapshot-name>\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk vm snapshot fresh-install\n"
        printf "  fedpunk vm snapshot my-vm before-fedpunk\n"
        return 0
    end

    set -l vm_name $DEFAULT_VM
    set -l snap_name ""

    if test (count $argv) -eq 1
        set snap_name $argv[1]
    else if test (count $argv) -ge 2
        set vm_name $argv[1]
        set snap_name $argv[2]
    end

    if test -z "$snap_name"
        printf "Error: Snapshot name required\n" >&2
        printf "Usage: fedpunk vm snapshot [vm-name] <snapshot-name>\n" >&2
        return 1
    end

    _require_vm "$vm_name"; or return 1

    printf "Creating snapshot '%s' for %s...\n" "$snap_name" "$vm_name"
    virsh snapshot-create-as "$vm_name" "$snap_name" "Snapshot created "(date '+%Y-%m-%d %H:%M:%S')
    printf "✓ Snapshot created\n"
end

function revert --description "Revert VM to a snapshot"
    if contains -- "$argv[1]" --help -h
        printf "Revert VM to a snapshot\n"
        printf "\n"
        printf "Usage: fedpunk vm revert [name] <snapshot-name>\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk vm revert fresh-install\n"
        printf "  fedpunk vm revert my-vm before-fedpunk\n"
        return 0
    end

    set -l vm_name $DEFAULT_VM
    set -l snap_name ""

    if test (count $argv) -eq 1
        set snap_name $argv[1]
    else if test (count $argv) -ge 2
        set vm_name $argv[1]
        set snap_name $argv[2]
    end

    if test -z "$snap_name"
        printf "Error: Snapshot name required\n" >&2
        printf "Usage: fedpunk vm revert [vm-name] <snapshot-name>\n" >&2
        return 1
    end

    _require_vm "$vm_name"; or return 1

    printf "Reverting %s to '%s'...\n" "$vm_name" "$snap_name"
    virsh snapshot-revert "$vm_name" "$snap_name"
    printf "✓ Reverted to snapshot\n"
end

function snapshots --description "List VM snapshots"
    if contains -- "$argv[1]" --help -h
        printf "List VM snapshots\n"
        printf "\n"
        printf "Usage: fedpunk vm snapshots [name]\n"
        return 0
    end

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    printf "Snapshots for %s:\n" "$vm_name"
    virsh snapshot-list "$vm_name"
end

function eject --description "Eject installation ISO"
    if contains -- "$argv[1]" --help -h
        printf "Eject installation ISO from VM\n"
        printf "\n"
        printf "Usage: fedpunk vm eject [name]\n"
        return 0
    end

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    set -l cdrom_dev (virsh dumpxml "$vm_name" | grep -A 2 "device='cdrom'" | grep "target dev" | sed -n "s/.*dev='\([^']*\)'.*/\1/p")

    if test -z "$cdrom_dev"
        printf "Error: No CD-ROM device found\n" >&2
        return 1
    end

    printf "Ejecting ISO from %s...\n" "$vm_name"
    virsh change-media "$vm_name" "$cdrom_dev" --eject --config
    printf "✓ ISO ejected\n"
end

function destroy --description "Delete VM and all data"
    if contains -- "$argv[1]" --help -h
        printf "Delete VM and all its data permanently\n"
        printf "\n"
        printf "Usage: fedpunk vm destroy [name]\n"
        return 0
    end

    set -l vm_name (test -n "$argv[1]" && echo $argv[1] || echo $DEFAULT_VM)
    _require_vm "$vm_name"; or return 1

    printf "WARNING: This will permanently delete %s and all its data!\n" "$vm_name"

    if not ui-confirm-smart --prompt "Are you sure?" --default no
        printf "Cancelled\n"
        return 0
    end

    # Stop if running
    if virsh list --state-running | grep -q "$vm_name"
        virsh destroy "$vm_name" 2>/dev/null
    end

    printf "Destroying %s...\n" "$vm_name"
    virsh undefine "$vm_name" --remove-all-storage --snapshots-metadata --nvram 2>/dev/null
    or virsh undefine "$vm_name" --remove-all-storage --snapshots-metadata 2>/dev/null
    printf "✓ VM destroyed\n"
end

function list --description "List VMs and status"
    if contains -- "$argv[1]" --help -h
        printf "List VMs and show status\n"
        printf "\n"
        printf "Usage: fedpunk vm list [name]\n"
        return 0
    end

    _ensure_libvirt; or return 1

    if test -z "$argv[1]"
        printf "All VMs:\n"
        virsh list --all
    else
        set -l vm_name $argv[1]
        _require_vm "$vm_name"; or return 1
        printf "Status for %s:\n" "$vm_name"
        virsh dominfo "$vm_name"
    end
end

function _get_current_branch
    # Get current branch from FEDPUNK_ROOT
    if test -d "$FEDPUNK_ROOT/.git"
        git -C "$FEDPUNK_ROOT" branch --show-current 2>/dev/null
    else
        echo "main"
    end
end

function install-cmd --description "Generate install command for current branch"
    if contains -- "$argv[1]" --help -h
        printf "Generate the curl install command for current branch\n"
        printf "\n"
        printf "Usage: fedpunk vm install-cmd\n"
        printf "\n"
        printf "Outputs a curl command that installs fedpunk from the current branch.\n"
        printf "Copy this into the VM to test the installation.\n"
        return 0
    end

    set -l branch (_get_current_branch)

    printf "curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/%s/boot.sh | FEDPUNK_REF=%s bash\n" "$branch" "$branch"
end

function test-install --description "Show install instructions for VM"
    if contains -- "$argv[1]" --help -h
        printf "Show install instructions for testing in VM\n"
        printf "\n"
        printf "Usage: fedpunk vm test-install\n"
        printf "\n"
        printf "Generates the curl command based on current git branch.\n"
        return 0
    end

    set -l branch (_get_current_branch)

    printf "To install Fedpunk in the VM, run:\n"
    printf "\n"
    printf "  curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/%s/boot.sh | FEDPUNK_REF=%s bash\n" "$branch" "$branch"
    printf "\n"
    printf "For terminal-only mode:\n"
    printf "\n"
    printf "  curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/%s/boot.sh | FEDPUNK_REF=%s FEDPUNK_TERMINAL_ONLY=1 bash\n" "$branch" "$branch"
end
