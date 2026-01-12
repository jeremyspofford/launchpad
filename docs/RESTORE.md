# System Restore Guide

This guide covers all methods for restoring your system after running the dotfiles setup.

## 📋 Table of Contents

- [Quick Reference](#quick-reference)
- [Understanding Restore Points](#understanding-restore-points)
- [Restore Methods](#restore-methods)
  - [1. Dotfiles Only](#1-restore-dotfiles-only)
  - [2. System Packages](#2-restore-system-packages)
  - [3. Full System (Timeshift)](#3-full-system-restore-timeshift)
- [Recovery Scenarios](#recovery-scenarios)
- [Timeshift Management](#timeshift-management)
- [Emergency Recovery](#emergency-recovery)
- [Best Practices](#best-practices)

---

## Quick Reference

| What's Wrong | Solution | Command |
|--------------|----------|---------|
| Don't like new dotfiles | Revert dotfiles | `./scripts/setup.sh --revert` |
| Package broke | Restore packages | `~/.system-snapshots/restore-packages-*.sh` |
| System won't boot | Boot Live USB + Timeshift | See [Emergency Recovery](#emergency-recovery) |
| Want to try again | Revert + re-run setup | `./scripts/setup.sh --revert && ./scripts/setup.sh` |

---

## Understanding Restore Points

The setup script creates **three levels** of protection:

### Level 1: Package Manifest (Always Created)
**Location:** `~/.system-snapshots/`

**What it contains:**
- List of all installed packages
- APT sources configuration
- Manually installed packages list
- Restore script

**Disk space:** ~1-5KB (minimal)

**What it can restore:** Exact package list (not configs)

### Level 2: Dotfile Backups (Always Created)
**Location:** `~/.dotfiles-backup/YYYYMMDD_HHMMSS/`

**What it contains:**
- Your original dotfiles (.zshrc, .bashrc, .gitconfig, etc.)
- Neovim configuration
- Ghostty configuration
- Any other files the setup modified
- Manifest of backed-up files

**Disk space:** ~10-100MB (depends on your configs)

**What it can restore:** Your dotfiles and user configs

### Level 3: Timeshift Snapshot (Optional)
**Location:** Timeshift manages this (usually `/timeshift/`)

**What it contains:**
- Entire system state
- All files, configs, and packages
- Boot configuration
- System settings

**Disk space:** 5-20GB (depends on system)

**What it can restore:** Everything (complete system state)

---

## Restore Methods

### 1. Restore Dotfiles Only

**When to use:**
- You don't like the new shell configuration
- New dotfiles have issues
- Want to try different settings
- Quick rollback needed

**How to restore:**

```bash
cd ~/workspace/dotfiles
./scripts/setup.sh --revert
```

**What happens:**
1. Removes all dotfile symlinks created by setup
2. Restores original files from most recent backup
3. Leaves dotfiles repo intact (you can try setup again)

**Restore to specific backup:**

```bash
# List available backups
./scripts/setup.sh --list-backups

# Revert to specific backup
./scripts/setup.sh --revert=20260111_143022
```

**After reverting:**
```bash
# Your original configs are back
# The dotfiles repo is still at ~/workspace/dotfiles

# Want to try again?
./scripts/setup.sh

# Or remove the repo entirely
rm -rf ~/workspace/dotfiles
```

---

### 2. Restore System Packages

**When to use:**
- A newly installed package is broken
- Want exact package versions from before
- Need to reproduce previous package state

**Find your restore script:**

```bash
# List available package manifests
ls -lt ~/.system-snapshots/

# You'll see:
# packages-20260111_143022.txt
# restore-packages-20260111_143022.sh
# manual-packages-20260111_143022.txt
```

**Run the restore:**

```bash
# Method 1: Use the restore script (easiest)
~/.system-snapshots/restore-packages-20260111_143022.sh

# Method 2: Manual restore
sudo dpkg --set-selections < ~/.system-snapshots/packages-20260111_143022.txt
sudo apt-get dselect-upgrade -y
```

**What this does:**
- Reinstalls all packages from the manifest
- Uses same versions (if still available in repos)
- Does NOT restore package configurations
- Does NOT remove packages installed after backup

**Limitations:**
- Package versions may have changed in repos
- Doesn't restore config files
- Newly installed packages remain (unless you remove them)

---

### 3. Full System Restore (Timeshift)

**When to use:**
- System is seriously broken
- Multiple things went wrong
- Want complete rollback
- System won't boot properly

#### GUI Method (Recommended)

```bash
# Launch Timeshift
sudo timeshift-gtk
```

**Steps:**
1. **Select snapshot:** Look for one labeled with your timestamp
   - Example: `2026-01-11 20:00:00 - Before dotfiles setup`
2. **Click "Restore"**
3. **Review changes:** Timeshift shows what will be restored
4. **Confirm:** Click "Next" then "Finish"
5. **Wait:** Let it complete (5-30 minutes depending on size)
6. **Reboot:** Restart your system

#### CLI Method

```bash
# List all snapshots
sudo timeshift --list

# Output example:
# Num  Name                  Tags  Description
# 0    2026-01-11_20-00-00   D     Before dotfiles setup - 20260111_200000

# Restore latest snapshot
sudo timeshift --restore

# Or restore specific snapshot
sudo timeshift --restore --snapshot "2026-01-11_20-00-00"

# Follow prompts, then reboot
sudo reboot
```

#### What Gets Restored

✅ **Restored:**
- All system files and configurations
- Installed packages and versions
- User home directories
- System settings
- Boot configuration

❌ **Not Restored (by default):**
- Files created after snapshot
- User data in `/home` (if you excluded it)

**Note:** Timeshift typically excludes `/home` by default to preserve user data. Check your Timeshift settings if you want `/home` included.

---

## Recovery Scenarios

### Scenario 1: "I Don't Like the New Shell"

**Symptoms:**
- Zsh is weird
- Missing my old aliases
- Prompt looks different

**Solution:**
```bash
cd ~/workspace/dotfiles
./scripts/setup.sh --revert

# Your old .zshrc is back!
# To change default shell back to bash:
chsh -s /bin/bash
```

---

### Scenario 2: "A Package is Broken"

**Symptoms:**
- Neovim won't start
- tmux crashes
- Tool has weird behavior

**Solution:**

```bash
# Option 1: Reinstall just that package
sudo apt install --reinstall neovim

# Option 2: Restore all packages from before setup
~/.system-snapshots/restore-packages-*.sh

# Option 3: Check if it's a config issue first
cd ~/workspace/dotfiles
./scripts/setup.sh --revert  # Restore old configs
```

---

### Scenario 3: "Multiple Things Broke"

**Symptoms:**
- Shell won't start properly
- Multiple commands missing
- System feels unstable

**Solution:**
```bash
# Use Timeshift for complete restore
sudo timeshift-gtk

# Or from CLI
sudo timeshift --restore

# After restore, system will be exactly as it was before setup
```

---

### Scenario 4: "System Won't Boot"

**Symptoms:**
- Stuck at login screen
- Black screen after boot
- Boot loop

**Solution:** See [Emergency Recovery](#emergency-recovery) below

---

## Emergency Recovery

### Booting from Live USB

If your system won't boot normally:

#### Step 1: Create/Use Ubuntu Live USB

1. Get a Ubuntu Live USB (same version as installed)
2. Boot from USB (usually F12, F2, or Del during startup)
3. Select "Try Ubuntu" (don't install)

#### Step 2: Install Timeshift in Live Environment

```bash
# In the live environment terminal:
sudo apt update
sudo apt install timeshift
```

#### Step 3: Restore from Snapshot

```bash
# Launch Timeshift
sudo timeshift-gtk
```

**In Timeshift:**
1. **Select your system disk** (usually the largest partition)
2. **Wait for snapshots to load**
3. **Select the snapshot** you want to restore
4. **Click "Restore"**
5. **Wait for completion** (may take 30+ minutes)
6. **Don't interrupt** even if it seems stuck

#### Step 4: Reboot

```bash
# Remove USB and reboot
sudo reboot now
```

Your system should boot normally now, restored to the snapshot state.

---

## Timeshift Management

### Viewing Snapshots

**GUI:**
```bash
sudo timeshift-gtk
```

**CLI:**
```bash
# List all snapshots with details
sudo timeshift --list

# Show more information
sudo timeshift --list --scripted
```

### Creating Manual Snapshots

```bash
# Create snapshot with description
sudo timeshift --create --comments "Before major system update"

# Create snapshot with tag
sudo timeshift --create --comments "Stable state" --tags D

# Tags:
# O = Ondemand (manual)
# D = Daily
# W = Weekly
# M = Monthly
```

### Deleting Old Snapshots

```bash
# Delete specific snapshot
sudo timeshift --delete --snapshot "2026-01-11_20-00-00"

# Delete all snapshots except the last N
sudo timeshift --delete-all

# Timeshift auto-deletes old snapshots based on your retention policy
```

### Configuring Timeshift

```bash
# Open settings
sudo timeshift-gtk

# Settings to configure:
# - Snapshot location (external drive recommended)
# - Schedule (daily, weekly, monthly)
# - Number of snapshots to keep
# - Include/exclude /home directory
# - Include/exclude specific directories
```

### Best Timeshift Settings

**Recommended Configuration:**

- **Location:** External drive or separate partition
- **Schedule:** 
  - Daily: Keep 5
  - Weekly: Keep 3
  - Monthly: Keep 2
- **Exclude:** `/home` (backup separately), `/tmp`, `/var/cache`
- **Include:** Everything else

**Why exclude /home?**
- User data changes frequently
- Makes snapshots smaller and faster
- Use separate backup solution for personal files
- Dotfiles backup already covers configs

---

## Best Practices

### Before Making Changes

```bash
# Create a manual snapshot before major changes
sudo timeshift --create --comments "Before installing new software"

# Or just use the setup script's built-in backup
./scripts/setup.sh --create-restore-point
```

### Regular Maintenance

```bash
# Weekly: Check Timeshift status
sudo timeshift --list

# Monthly: Clean up old snapshots
sudo timeshift-gtk  # Review and delete old ones

# As needed: Test restore on non-critical system
```

### Storage Management

```bash
# Check Timeshift disk usage
sudo du -sh /timeshift

# Check backup locations
ls -lh ~/.dotfiles-backup/
ls -lh ~/.system-snapshots/

# Clean old dotfile backups (keep last 5)
cd ~/.dotfiles-backup
ls -t | tail -n +6 | xargs rm -rf
```

### Documentation

**Keep notes on:**
- When you created snapshots
- What changes you made
- Which snapshot to restore to
- Custom configurations you added

**Example log:**
```
2026-01-11 20:00 - Clean install + dotfiles setup
2026-01-15 14:30 - Added custom aliases, working well
2026-01-20 09:00 - Before trying new terminal emulator
```

---

## Restore Decision Tree

```
Is something broken?
│
├─ Just dotfiles/configs?
│  └─ ./scripts/setup.sh --revert
│
├─ One package broken?
│  └─ sudo apt install --reinstall PACKAGE
│
├─ Multiple packages broken?
│  └─ ~/.system-snapshots/restore-packages-*.sh
│
├─ System unstable but boots?
│  └─ sudo timeshift --restore
│
└─ System won't boot?
   └─ Boot Live USB → Install Timeshift → Restore
```

---

## Additional Resources

### Timeshift Documentation
- [Timeshift GitHub](https://github.com/teejee2008/timeshift)
- [Timeshift Wiki](https://github.com/teejee2008/timeshift/wiki)

### Ubuntu Recovery
- [Ubuntu Recovery Mode](https://wiki.ubuntu.com/RecoveryMode)
- [Ubuntu Live USB Guide](https://ubuntu.com/tutorials/try-ubuntu-before-you-install)

### Backup Best Practices
- Keep 3 copies of important data (3-2-1 rule)
- Test restores regularly
- Store backups on different media/locations
- Automate backups when possible

---

## Troubleshooting

### "Timeshift won't start"

```bash
# Check if BTRFS or rsync is configured
sudo timeshift --list

# Reconfigure if needed
sudo timeshift --setup
```

### "Restore failed halfway"

**Don't panic!**
- System is likely in inconsistent state
- Boot from Live USB
- Try restore again
- If still fails, restore to earlier snapshot

### "Can't find my backup"

```bash
# Check dotfile backups
ls -la ~/.dotfiles-backup/

# Check package manifests
ls -la ~/.system-snapshots/

# Check Timeshift snapshots
sudo timeshift --list

# Check Timeshift backup location
cat /etc/timeshift/timeshift.json | grep backup_device_uuid
```

### "Restored but shell still broken"

```bash
# Try resetting shell to bash
chsh -s /bin/bash

# Log out and back in
# Then check your .bashrc
cat ~/.bashrc

# If still issues, restore dotfiles again
cd ~/workspace/dotfiles
./scripts/setup.sh --revert
```

---

## Questions?

If you encounter issues not covered here:

1. **Check the logs:**
   ```bash
   # Dotfiles setup log (if kept)
   cat ~/workspace/dotfiles/setup.log
   
   # Timeshift log
   sudo timeshift --list
   ```

2. **Ask for help:**
   - Open an issue in the dotfiles repo
   - Include: what you tried, error messages, system info

3. **Last resort:**
   - Boot Live USB
   - Backup your important files from `/home`
   - Reinstall Ubuntu
   - Try setup again (with lessons learned!)

Remember: The whole point of these restore points is to make recovery easy. Don't hesitate to use them!
