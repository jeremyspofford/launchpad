# Terminal Font Setup for Icons

After running the dotfiles setup, the **JetBrainsMono Nerd Font** is automatically installed to `~/.local/share/fonts/`. However, you need to configure your terminal to use it for icons to display properly in Neovim/LazyVim.

## Quick Setup by Terminal

### GNOME Terminal (Default Ubuntu Terminal)

1. Open Terminal
2. Click **☰** menu → **Preferences**
3. Select your profile (usually "Unnamed")
4. Go to **Text** tab
5. ✅ Enable **Custom font**
6. Click the font button
7. Search for: `JetBrainsMono Nerd Font Mono`
8. Select it and close
9. Restart terminal

### Ghostty

Edit `~/.config/ghostty/config`:
```
font-family = "JetBrainsMono Nerd Font Mono"
```

Save and restart Ghostty.

### Alacritty

Edit `~/.config/alacritty/alacritty.yml`:
```yaml
font:
  normal:
    family: "JetBrainsMono Nerd Font Mono"
  size: 12.0
```

Save and restart Alacritty.

### Kitty

Edit `~/.config/kitty/kitty.conf`:
```
font_family JetBrainsMono Nerd Font Mono
font_size 12.0
```

Save and restart Kitty.

### Warp

1. Open Warp settings (⌘,)
2. Go to **Appearance** → **Text**
3. Change font to: `JetBrainsMono Nerd Font Mono`
4. Apply changes

### Windows Terminal / WSL

1. Open Windows Terminal
2. Settings (Ctrl+,)
3. Profiles → Select your WSL profile
4. Appearance tab
5. Font face: `JetBrainsMono Nerd Font Mono`
6. Save

## Verify Font is Working

1. Open terminal with the new font
2. Test with icons:
   ```bash
   echo "      "
   ```
   You should see actual icons, not boxes

3. Open Neovim:
   ```bash
   nvim
   ```

4. You should see:
   - ✅ Icons in the file explorer (neo-tree)
   - ✅ Fancy separators and symbols
   - ✅ Git status icons
   - ✅ File type icons

## Troubleshooting

### Icons Still Show as Boxes or Weird Characters

**Solution:** Run these commands in Neovim:
```vim
:Lazy sync
:TSUpdate
```
Then restart Neovim.

### Font Not Appearing in Terminal's Font List

**Solution:** Rebuild font cache:
```bash
fc-cache -fv ~/.local/share/fonts
```

Then verify font is installed:
```bash
fc-list | grep JetBrains
```

You should see multiple JetBrainsMono fonts listed.

### Still Having Issues?

1. **Check font installation:**
   ```bash
   ls ~/.local/share/fonts/JetBrainsMono/
   ```
   You should see multiple `.ttf` files.

2. **Reinstall font if needed:**
   ```bash
   cd /tmp/dotfiles
   ./scripts/unified_app_manager.sh
   # Select only neovim, it will reinstall the font
   ```

3. **Restart your system** - Sometimes font cache needs a full restart to recognize new fonts.

## Why This Font?

**JetBrainsMono Nerd Font** includes:
- 💻 Programming ligatures
- 🎨 Thousands of icons and glyphs
- 📁 File type icons
- 🔀 Git status symbols
- ⚡ Powerline symbols
- 🎯 Devicons

Perfect for modern terminal development! ✨
