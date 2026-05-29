# EyeBreak 👁️

**Rest your eyes every 20 minutes.**  
A minimal macOS app that gives you a full-screen break to protect your eyes.

---

### Features
- Works on **Apple Silicon** (M1, M2, M3, M4)
- 20 minutes work → 20 seconds black screen break
- Full screen on all monitors
- Press **ESC** or click "Skip Break" to exit early
- Runs quietly in the menu bar
- Auto-starts when you log in
- Very lightweight

---

### How to Install (Super Easy)

1. Download `EyeBreak-macOS.zip`
2. Open the downloaded `.zip` file
3. Drag **EyeBreak.app** into your **Applications** folder
4. Eject the DMG
5. Open `EyeBreak.app` from Applications folder  
   *(First time: Right-click → Open)*

The app will run in the background and show the 👁️ icon in your menu bar.

---

### Releases
- **macOS (Apple Silicon)** - Current Version
- Windows version coming soon

---

### Building from Source (Optional)

```bash
clang++ EyeBreak.mm -o EyeBreak -framework Cocoa -std=c++17 -O2
