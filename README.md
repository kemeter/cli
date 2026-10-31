# Kemeter CLI

Manage your [Kemeter](https://kemeter.cloud) applications from your terminal.

This repository publishes the binaries of the CLI. Its source code is not public.

## Install

Linux and macOS:

```sh
curl -fsSL https://cli.kemeter.cloud/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://cli.kemeter.cloud/install.ps1 | iex
```

Run the same command again to update. To read a script before running it, open
its URL, or download a binary directly from the
[releases](https://github.com/kemeter/cli/releases).

## Verify a download

Each release has a `SHA256SUMS` file, signed with [cosign](https://docs.sigstore.dev/cosign/).
The install scripts check the checksums. To also check the signature:

```sh
cosign verify-blob SHA256SUMS \
  --bundle SHA256SUMS.sigstore.json \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/kemeter/kemeter/\.github/workflows/cli-release\.yml@refs/tags/cli-v'
sha256sum --check --ignore-missing SHA256SUMS
```

## License

See [LICENSE](./LICENSE). The third-party software included in the binary is listed
in `THIRD-PARTY-NOTICES.txt`, attached to each release.

## Security

Please report a vulnerability privately through
[GitHub security advisories](https://github.com/kemeter/cli/security/advisories/new).
