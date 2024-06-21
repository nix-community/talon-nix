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

## Can I use Talon Beta?

Yes, but please remember the Talon Beta URLs are meant to be kept private. You can manually override the talon-nix
flake, but it is important that you DO NOT include the hardcoded URLs in a public repository. You should keep the URL
private by importing a secrets repo into your config flake, and have the beta URL inside of the secret flake. However,
this will expose the URL in the nix store, so if you are using a shared system, you will need to use some other
approach.

The following is an example of how this might look:

```nix
    nixpkgs = {
        overlays = [
        inputs.talon-nix.overlays.default
        (final: prev: {
            talon-unwrapped = prev.talon-unwrapped.overrideAttrs (oldAttrs: {
            version = "0.4.0-359-g5c35";
            src = builtins.fetchurl {
                url = inputs.nix-secrets.talon-beta-url;
                sha256 = "sha256:07ia3cnr1ayckcffr3zw6l9j3fz8ywxcxjw68ba647994s2n2zfa";
            };
            });
        })
        ];
    };
```

