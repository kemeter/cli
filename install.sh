#!/bin/sh
# Installs the Kemeter CLI on Linux and macOS.
#
#   curl -fsSL https://cli.kemeter.cloud/install.sh | sh
#
# KEMETER_VERSION       version to install, e.g. v0.1.0 (default: the latest)
# KEMETER_INSTALL_DIR   where to put the binary (default: ~/.local/bin)

set -eu

# Everything runs from main, called on the last line: a download cut halfway
# through leaves a function that never ran, not half an installation.
main() {
    repository="https://github.com/kemeter/cli/releases"
    install_dir="${KEMETER_INSTALL_DIR:-$HOME/.local/bin}"

    case "$(uname -s)" in
        Linux) system="unknown-linux-musl" ;;
        Darwin) system="apple-darwin" ;;
        *) fail "unsupported system: $(uname -s). On Windows, use install.ps1." ;;
    esac

    case "$(uname -m)" in
        x86_64 | amd64) architecture="x86_64" ;;
        aarch64 | arm64) architecture="aarch64" ;;
        *) fail "unsupported architecture: $(uname -m)" ;;
    esac

    if [ -n "${KEMETER_VERSION:-}" ]; then
        base_url="$repository/download/$KEMETER_VERSION"
    else
        base_url="$repository/latest/download"
    fi

    archive="kemeter-$architecture-$system.tar.gz"
    directory="$(mktemp -d)"
    trap 'rm -rf "$directory"' EXIT

    echo "Downloading $archive"
    curl -fsSL "$base_url/$archive" -o "$directory/$archive"
    curl -fsSL "$base_url/SHA256SUMS" -o "$directory/SHA256SUMS"

    verify "$directory" "$archive"

    tar -xzf "$directory/$archive" -C "$directory"
    mkdir -p "$install_dir"
    # Moved rather than overwritten in place: replacing a running binary fails
    # with "text file busy", and a rename is all or nothing.
    cp "$directory/kemeter" "$install_dir/.kemeter.new"
    chmod 755 "$install_dir/.kemeter.new"
    mv "$install_dir/.kemeter.new" "$install_dir/kemeter"

    echo "Installed $("$install_dir/kemeter" --version) in $install_dir"

    case ":$PATH:" in
        *":$install_dir:"*) ;;
        *) echo "Add $install_dir to your PATH to run it." ;;
    esac
}

verify() {
    expected="$(awk -v name="$2" '$2 == name { print $1 }' "$1/SHA256SUMS")"
    [ -n "$expected" ] || fail "no checksum published for $2"

    if command -v sha256sum >/dev/null 2>&1; then
        actual="$(sha256sum "$1/$2" | awk '{ print $1 }')"
    else
        actual="$(shasum -a 256 "$1/$2" | awk '{ print $1 }')"
    fi

    [ "$expected" = "$actual" ] || fail "checksum mismatch for $2"
}

fail() {
    echo "Error: $1" >&2
    exit 1
}

main
