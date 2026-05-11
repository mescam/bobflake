# bobflake

Nix flake for [IBM Bob Shell](https://bob.ibm.com) — an AI-powered terminal assistant.

[![CI](https://github.com/mescam/bobflake/actions/workflows/ci.yml/badge.svg)](https://github.com/mescam/bobflake/actions/workflows/ci.yml)
[![Update](https://github.com/mescam/bobflake/actions/workflows/update.yml/badge.svg)](https://github.com/mescam/bobflake/actions/workflows/update.yml)

## Install

### Run without installing

```bash
nix run github:mescam/bobflake
```

### Install to profile

```bash
nix profile install github:mescam/bobflake
```

### Use in a flake

```nix
{
  inputs.bobflake.url = "github:mescam/bobflake";

  outputs = { self, nixpkgs, bobflake, ... }: {
    # Option 1: overlay
    nixpkgs.overlays = [ bobflake.overlays.default ];
    # then use pkgs.bobshell

    # Option 2: direct reference
    environment.systemPackages = [ bobflake.packages.${system}.default ];
  };
}
```

## Supported platforms

- `aarch64-darwin` (Apple Silicon)
- `x86_64-darwin` (Intel Mac)
- `x86_64-linux`
- `aarch64-linux`

## How it works

This flake fetches the official Bob Shell tarball from IBM, wraps the bundled
JavaScript with Node.js via `makeWrapper`, and exposes the `bob` command.

No compilation. No npm install. Pure Nix packaging.

## Updating

A GitHub Actions workflow checks daily for new Bob Shell releases and opens a
PR automatically when a new version is available.

## License

The Nix packaging code in this repository is [MIT](LICENSE).

IBM Bob Shell itself is proprietary software subject to IBM's license terms.
