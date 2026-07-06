#!/usr/bin/env python3
"""Generate Homebrew `resource` blocks for xeneon-touch's Python dependencies.

`brew update-python-resources` can't resolve this project: its pyproject.toml
lives in the repo's userspace/ subdirectory, not at the source-tarball root, so
pip can't find the package. This script sidesteps that — it installs the three
top-level dependencies into a throwaway virtualenv, reads the exact resolved
versions (including the transitive pyobjc packages), and prints ready-to-paste
`resource` stanzas with each sdist's URL and sha256 from PyPI.

Usage (on your Mac):
    python3 generate_resources.py > resources.txt
Then paste the contents into Formula/xeneon-touch.rb where the placeholder
comment is (between `depends_on` and `def install`).
"""
import json
import subprocess
import sys
import tempfile
import urllib.request
import venv
from pathlib import Path

# The daemon's declared dependencies (see userspace/pyproject.toml).
TOP_LEVEL = [
    "hidapi",
    "pyobjc-framework-Quartz",
    "pyobjc-framework-ApplicationServices",
]


def main() -> int:
    tmp = Path(tempfile.mkdtemp(prefix="xeneon-brew-"))
    env_dir = tmp / "venv"
    print(f"# building resolver venv in {env_dir} ...", file=sys.stderr)
    venv.create(env_dir, with_pip=True)
    pip = str(env_dir / "bin" / "pip")

    subprocess.run([pip, "install", "-q", "--upgrade", "pip"], check=True)
    subprocess.run([pip, "install", "-q", *TOP_LEVEL], check=True)

    frozen = subprocess.run(
        [pip, "freeze"], check=True, capture_output=True, text=True
    ).stdout

    pkgs = {}
    for line in frozen.splitlines():
        if "==" in line:
            name, ver = line.split("==", 1)
            pkgs[name.strip()] = ver.strip()

    blocks = []
    for name in sorted(pkgs, key=str.lower):
        ver = pkgs[name]
        with urllib.request.urlopen(f"https://pypi.org/pypi/{name}/{ver}/json") as r:
            data = json.load(r)
        sdist = next((u for u in data["urls"] if u["packagetype"] == "sdist"), None)
        if sdist is None:
            print(f"# WARNING: no sdist for {name} {ver}; falling back to a wheel",
                  file=sys.stderr)
            sdist = data["urls"][0]
        blocks.append(
            f'  resource "{name}" do\n'
            f'    url "{sdist["url"]}"\n'
            f'    sha256 "{sdist["digests"]["sha256"]}"\n'
            f"  end"
        )

    print(f"# {len(blocks)} resources for xeneon-touch", file=sys.stderr)
    print("\n\n".join(blocks))
    return 0


if __name__ == "__main__":
    sys.exit(main())
