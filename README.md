# Nix packages for Talon Voice

Automatically managed Nix package for [Talon voice](https://talonvoice.com/).
Note that only the very latest version of Talon is supported.

Because upstream does not supply versioned downloads the expressions _will_ break when upstream version bumps.

# Manually Updating Talon Version

If there is a small Talon update that doesn't break dependencies, you should be able
to run `scrape.py download` to fetch the new sha256 into `src.json` and then rebuild
the flake without any issues.

# FAQ

## Can I Auto Update?

Talon is not able to auto-update itself when run from this nix file, as the
nix store is read-only. If you require auto-update functionality for now it is
recommended you manually download talon tarball, extract it, and use
the `steam-run` package on the `run.sh` file inside. Talon should run and be
able to auto-update without any issues.

## Why No System Tray Icon?

The old system tray is gone from many window managers. This nix file includes the
`snixembed` package which can be manually run to get the Talon tray icon
showing up.

# Can I use Talon Beta?

The Talon Beta URLs and tarballs are private and also change across each release.
If you want to run the Talon Beta, download a beta tarball from the URLs hosted in
the `#beta` slack channel, then use the `steam-run` approach mentioned above.
