# homebrew-xeneon-edge

A [Homebrew](https://brew.sh) tap for **xeneon-touch** — the single-touch daemon
for the Corsair Xeneon Edge touchscreen on macOS.

Main project: https://github.com/Myseri/xeneon-edge-multitouch-macos

## Install (for users)

```bash
brew tap Myseri/xeneon-edge
brew install xeneon-touch
brew services start xeneon-touch      # starts now + at every login
```

Then grant the two one-time permissions Homebrew prints in the caveats
(**Input Monitoring** and **Accessibility**, to the python binary shown), and
restart once:

```bash
brew services restart xeneon-touch
```

