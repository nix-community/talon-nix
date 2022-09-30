#!/usr/bin/env python3
from bs4 import BeautifulSoup
import requests
import sys
import os


CHANGELOG_URL = "https://talonvoice.com/dl/latest/changelog.html"
TALON_URL = "https://talonvoice.com/dl/latest/talon-linux.tar.xz"


def download_file(url, target):
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(target, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)


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

        download_file(TALON_URL, f"artifacts/talon_linux-{version}.tar.xz")

    elif command == "version":
        print(get_version())

    else:
        raise ValueError(f"Command '{command}' unhandled")
