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

Updating later is just:

```bash
brew upgrade xeneon-touch
```

> **Single-touch only.** The 10-finger digitizer is firmware-gated on macOS —
> see the main project for the full explanation.

## Maintaining this tap

The formula is authored but not yet finalized — two steps remain, both run on a
Mac with Homebrew:

1. **Tag a release** in the main repo so the source tarball is stable:

   ```bash
   cd xeneon-edge-multitouch-macos
   git tag v0.1.0 && git push origin v0.1.0
   ```

2. **Fill the checksum and resources** in `Formula/xeneon-touch.rb`:

   ```bash
   # a) real tarball checksum
   curl -sL https://github.com/Myseri/xeneon-edge-multitouch-macos/archive/refs/tags/v0.1.0.tar.gz \
     | shasum -a 256
   # paste it over the sha256 placeholder

   # b) auto-generate all Python resource blocks (hidapi + the pyobjc tree)
   brew update-python-resources Formula/xeneon-touch.rb
   ```

3. **Test locally before publishing:**

   ```bash
   brew install --build-from-source ./Formula/xeneon-touch.rb
   brew test xeneon-touch
   brew audit --strict --new xeneon-touch
   ```

4. **Publish:** create a GitHub repo named exactly `homebrew-xeneon-edge` under
   your account and push this directory. The `brew tap Myseri/xeneon-edge`
   command above then works for anyone.

### Notes

- The formula pins `python@3.13`; bump it if you want a newer interpreter.
- `brew services` installs its own LaunchAgent, so it replaces the `install.sh`
  script in the main repo for people who install via Homebrew. The two TCC
  permissions still can't be automated — that step is inherently manual.
- On a new release, bump `url`/`sha256`, re-run `brew update-python-resources`,
  and `brew audit` again.
