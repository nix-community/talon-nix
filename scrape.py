#!/usr/bin/env python3
from bs4 import BeautifulSoup
import requests
import hashlib
import json
import sys
import os
from enum import StrEnum, auto

TALON_URL_BASE = "https://talonvoice.com/dl/latest/talon"
class TalonUrl(StrEnum):
    linux = f"{TALON_URL_BASE}-linux.tar.xz"
    darwin = f"{TALON_URL_BASE}-mac.dmg"


CHANGELOG_URL = "https://talonvoice.com/dl/latest/changelog.html"
USER_AGENT = "nix-community scraper"

def download_file(url, target):
    h = hashlib.sha256()

    headers = {"User-Agent": USER_AGENT}
    print(f'Downloading {url}')

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

    # This is prone to breakage, as it was h2 in the past, but is now h1
    for title in soup.find_all("h1"):
        return title.text.split(" ")[0]

    raise ValueError("No titles found")


if __name__ == "__main__":
    exe_name = sys.argv.pop(0)
    
    if len(sys.argv) < 1:
        print(
            f'Usage: {exe_name} <command>',
            '  download - Download latest tarball and place info into src.json',
            '  version - Print the latest talon version available',
            sep="\n"
        )
        sys.exit(0)

    command = sys.argv.pop(0)

    if command == "download":
        try:
            os.mkdir("artifacts")
        except FileExistsError:
            pass

        version = get_version()

        info = { "version": version }
        for talonUrl in TalonUrl:
            last_slash = talonUrl.value.rfind("/")
            first_period = talonUrl.value.find(".", last_slash)
            ext = talonUrl.value[first_period:]
            info[talonUrl.name] = { "sha256": download_file(talonUrl.value, f"artifacts/talon_{talonUrl.name}-{version}{ext}") }

        with open("talon/info.json", "w") as f:
            json.dump(info, f, indent=4)

    elif command == "version":
        print(get_version())

    else:
        raise ValueError(f"Command '{command}' unhandled")
