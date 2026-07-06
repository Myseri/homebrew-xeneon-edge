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
  # Generated with ./generate_resources.py (brew update-python-resources can't
  # resolve this project — its pyproject.toml is in the userspace/ subdir).
  # Regenerate on each release and paste the new blocks here.
  resource "hidapi" do
    url "https://files.pythonhosted.org/packages/74/f6/caad9ed701fbb9223eb9e0b41a5514390769b4cb3084a2704ab69e9df0fe/hidapi-0.15.0.tar.gz"
    sha256 "ecbc265cbe8b7b88755f421e0ba25f084091ec550c2b90ff9e8ddd4fcd540311"
  end

  resource "pyobjc-core" do
    url "https://files.pythonhosted.org/packages/b4/b1/729f7458a63758bd21716648a8abcd9a0c8f2d2e9897763c8a1a1c7fd31b/pyobjc_core-12.2.1.tar.gz"
    sha256 "7a7b9b018402342cf32bf1956366896350fbe5c0478cb3ef59778f77abed7f07"
  end

  resource "pyobjc-framework-ApplicationServices" do
    url "https://files.pythonhosted.org/packages/5e/4d/0ebdd8144aba94b8fe9828ccee5616a4bf53d1f8bc51cff55f3cce86d695/pyobjc_framework_applicationservices-12.2.1.tar.gz"
    sha256 "048ea663c9ac75c44a15dc7d5b8d78cbb4c97bf1c76e83835e8d5498e184001f"
  end

  resource "pyobjc-framework-Cocoa" do
    url "https://files.pythonhosted.org/packages/51/34/fbe38a204643aa4e1b91391cdce07a34da565a69171ebcad08de7438a556/pyobjc_framework_cocoa-12.2.1.tar.gz"
    sha256 "b94b37fe5730e5ae1fb0052912cd174e6ec329b0bfba4a012ae5db1014b5864b"
  end

  resource "pyobjc-framework-CoreText" do
    url "https://files.pythonhosted.org/packages/5a/9c/4c7f452059dc1d3845b8e627b9113c247a997b9b07518e848c2ab7ff3149/pyobjc_framework_coretext-12.2.1.tar.gz"
    sha256 "af740e784d7c592c34025ec7165f4f6c1a69b5a2d9075f06e41e4f77c212aed2"
  end

  resource "pyobjc-framework-Quartz" do
    url "https://files.pythonhosted.org/packages/3b/f6/2a8b84dbf1fe7c04dd96ea73d991678d4e09a909f51971ecc51629bb2ab4/pyobjc_framework_quartz-12.2.1.tar.gz"
    sha256 "b3b8b6f71e66147f8ff9e6213864cc8527e3a0b1ee90835b93ce221f4802d9b0"
  end

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
