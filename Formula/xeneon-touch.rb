class XeneonTouch < Formula
  include Language::Python::Virtualenv

  desc "Single-touch daemon for the Corsair Xeneon Edge touchscreen on macOS"
  homepage "https://github.com/Myseri/xeneon-edge-multitouch-macos"
  url "https://github.com/Myseri/xeneon-edge-multitouch-macos/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "ea75b79c40b04abd8e92e2b9241eee8f7d616a7f2d984fb32a71afe6c0119d00"
  license "MIT"

  depends_on "hidapi"
  depends_on "python@3.13"
  depends_on :macos

  # ── Python dependencies ──────────────────────────────────────────────────
  # These are filled in automatically. After setting the url/sha256 above, run
  # this on your Mac and it inserts every resource block (hidapi, pyobjc-core,
  # pyobjc-framework-Cocoa/CoreText/Quartz/ApplicationServices, ...):
  #
  #     brew update-python-resources Formula/xeneon-touch.rb
  #
  # >>> generated `resource "..." do ... end` blocks go here <<<

  def install
    # The Python package lives in the repo's userspace/ subdirectory.
    cd "userspace" do
      virtualenv_install_with_resources
    end
  end

  service do
    run [opt_bin/"xeneon-touch"]
    keep_alive true
    log_path "/tmp/xeneon-touch.log"
    error_log_path "/tmp/xeneon-touch.log"
    # A GUI LaunchAgent doesn't inherit the shell's dynamic-library path, so
    # point the loader at Homebrew's libhidapi explicitly.
    environment_variables DYLD_FALLBACK_LIBRARY_PATH: Formula["hidapi"].opt_lib
  end

  def caveats
    <<~EOS
      xeneon-touch needs two one-time macOS permissions. macOS prompts for
      Input Monitoring on first run, and the daemon requests Accessibility
      itself — accept both dialogs, granting them to this binary:

        #{opt_libexec}/bin/python3

      System Settings -> Privacy & Security ->
        - Input Monitoring   (to read the touch device)
        - Accessibility      (to inject clicks)

      Start it now and enable it at every login with:
        brew services start xeneon-touch

      After granting the permissions, restart it once:
        brew services restart xeneon-touch

      Single-touch only: the 10-finger digitizer is firmware-gated on macOS.
      Details: #{homepage}
    EOS
  end

  test do
    assert_match "xeneon-touch #{version}",
                 shell_output("#{bin}/xeneon-touch --version")
  end
end
