# Fan Control Plugin

Automatic fan speed control for Aquacomputer Octo controller based on CPU temperature.

## Features

- **Temperature-based fan curve** - Automatically adjusts fan speeds based on CPU temp
- **Manual control** - Set individual or all fans to specific speeds
- **Status monitoring** - View current fan speeds, PWM values, and temperatures
- **Systemd service** - Optional daemon for continuous monitoring

## Installation

### Deploy Plugin

```bash
# From fedpunk root
fedpunk module deploy plugins/fan-control

# Or add to your desktop mode
echo "  - plugins/fan-control" >> profiles/dev/modes/desktop.yaml
fish install.fish --mode desktop
```

This will stow the scripts to `~/.local/bin/`:
- `fan-status` - View fan speeds and temps
- `fan-set` - Manually control fan speeds
- `fan-curve` - Temperature-based automatic control

## Usage

### View Current Status

```bash
fan-status
```

Shows:
- All fan speeds (RPM)
- PWM settings (0-255 / 0-100%)
- System temperatures

### Manual Fan Control

Set individual fan:
```bash
sudo fan-set 1 50    # Fan 1 to 50%
```

Set all fans:
```bash
sudo fan-set all 60  # All fans to 60%
```

Turn off a fan:
```bash
sudo fan-set 4 0     # Fan 4 off
```

### Automatic Temperature-Based Control

One-time adjustment:
```bash
sudo fan-curve
```

Run as daemon (continuous monitoring):
```bash
sudo fan-curve --daemon
```

### Install as Systemd Service

**Note:** The service requires root privileges to write to `/sys/class/hwmon/hwmon5/pwm*` files.

**Option 1: Run as system service** (recommended)

```bash
# Copy to system location
sudo cp ~/.config/systemd/user/fan-control.service /etc/systemd/system/

# Edit to use absolute path
sudo sed -i 's|ExecStart=.*|ExecStart=/home/softmax/.local/bin/fan-curve --daemon|' /etc/systemd/system/fan-control.service

# Enable and start
sudo systemctl enable fan-control.service
sudo systemctl start fan-control.service

# Check status
sudo systemctl status fan-control.service

# View logs
sudo journalctl -u fan-control.service -f
```

**Option 2: Add udev rule for user access** (alternative)

Create `/etc/udev/rules.d/99-hwmon.rules`:
```
KERNEL=="hwmon5", SUBSYSTEM=="hwmon", ACTION=="add", RUN+="/bin/chmod -R 666 /sys/class/hwmon/hwmon5/pwm*"
```

Then reload udev and run as user service:
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger

# Enable user service
systemctl --user enable fan-control.service
systemctl --user start fan-control.service
```

## Fan Curve Configuration

Default curve (edit in `~/.local/bin/fan-curve`):

| Temperature | Fan Speed |
|-------------|-----------|
| < 40°C      | 30%       |
| 40°C        | 35%       |
| 50°C        | 45%       |
| 60°C        | 60%       |
| 70°C        | 75%       |
| 80°C        | 90%       |
| 85°C+       | 100%      |

To customize, edit the `FAN_CURVE` array in the script:

```bash
nvim ~/.local/bin/fan-curve
```

```bash
declare -A FAN_CURVE=(
    [0]=25      # Quieter at idle
    [40]=30
    [50]=40
    # ... customize as needed
)
```

## Hardware Details

- **Controller:** Aquacomputer Octo (USB device)
- **Location:** `/sys/class/hwmon/hwmon5/`
- **Channels:** 8 PWM outputs, 9 fan inputs (including flow sensor)
- **PWM Range:** 0-255 (0% - 100%)
- **Temperature Source:** CPU (k10temp: `/sys/class/hwmon/hwmon3/temp1_input`)

## Troubleshooting

### Permission Denied

The PWM control files require root access. Either:
1. Run commands with `sudo`
2. Install as system service (recommended)
3. Add udev rule for user access (see above)

### Controller Not Found

Check if hwmon5 exists:
```bash
ls -l /sys/class/hwmon/hwmon5/
cat /sys/class/hwmon/hwmon5/name
```

Should show "octo". If not, find your controller:
```bash
for i in /sys/class/hwmon/hwmon*/name; do echo "$i: $(cat $i)"; done
```

Update `HWMON` path in scripts if needed.

### Fans Not Changing Speed

1. Check current PWM value:
   ```bash
   cat /sys/class/hwmon/hwmon5/pwm1
   ```

2. Try manual control:
   ```bash
   sudo fan-set 1 50
   ```

3. Verify fan is connected and showing RPM in `fan-status`

## Uninstallation

```bash
# Stop and disable service if running
sudo systemctl stop fan-control.service
sudo systemctl disable fan-control.service
sudo rm /etc/systemd/system/fan-control.service

# Or user service
systemctl --user stop fan-control.service
systemctl --user disable fan-control.service

# Undeploy plugin (removes scripts from ~/.local/bin)
fedpunk module undeploy plugins/fan-control

# Or remove from desktop mode and reinstall
# (edit modes/desktop.yaml to remove - plugins/fan-control)
```

## See Also

- [Aquacomputer Linux Driver](https://github.com/aleksamagicka/aquacomputer_d5next-hwmon)
- [lm-sensors Documentation](https://hwmon.wiki.kernel.org/)
- Fedpunk Plugin System: `profiles/dev/README.md`
