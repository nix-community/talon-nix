#!/usr/bin/env python3
from bs4 import BeautifulSoup
import requests
import hashlib
import json
import sys
import os


CHANGELOG_URL = "https://talonvoice.com/dl/latest/changelog.html"
TALON_URL = "https://talonvoice.com/dl/latest/talon-linux.tar.xz"


USER_AGENT = "nix-community scraper"


def download_file(url, target):
    h = hashlib.sha256()

    headers = {"User-Agent": USER_AGENT}

    with requests.get(url, stream=True, headers=headers) as r:
        r.raise_for_status()
        with open(target, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
                h.update(chunk)

    return h.hexdigest()


def get_version() -> str:
    """Find the latest version from the changelog"""
    r = requests.get(CHANGELOG_URL)
    soup = BeautifulSoup(r.text, features="lxml")

    for title in soup.find_all("h2"):
        return title.text.split(" ")[0]

    raise ValueError("No titles found")


if __name__ == "__main__":

    command = sys.argv[1]

    if command == "download":
        try:
            os.mkdir("artifacts")
        except FileExistsError:
            pass

        version = get_version()

        sha256 = download_file(TALON_URL, f"artifacts/talon_linux-{version}.tar.xz")

        with open("src.json", "w") as f:
            f.write(json.dumps({
                "sha256": sha256,
                "version": version,
            }))
            f.write("\n")

    elif command == "version":
        print(get_version())

    else:
        raise ValueError(f"Command '{command}' unhandled")
