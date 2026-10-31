# Installs the Kemeter CLI on Windows.
#
#   irm https://cli.kemeter.cloud/install.ps1 | iex
#
# KEMETER_VERSION       version to install, e.g. v0.1.0 (default: the latest)
# KEMETER_INSTALL_DIR   where to put the binary (default: %LOCALAPPDATA%\Programs\kemeter)

$ErrorActionPreference = 'Stop'

function Install-Kemeter {
    $repository = 'https://github.com/kemeter/cli/releases'
    $installDir = if ($env:KEMETER_INSTALL_DIR) { $env:KEMETER_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\kemeter' }
    $baseUrl = if ($env:KEMETER_VERSION) { "$repository/download/$env:KEMETER_VERSION" } else { "$repository/latest/download" }

    # There is no native arm64 build: Windows on arm runs this one under emulation.
    $archive = 'kemeter-x86_64-pc-windows-msvc.zip'
    $directory = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $directory | Out-Null

    try {
        Write-Host "Downloading $archive"
        Invoke-WebRequest "$baseUrl/$archive" -OutFile (Join-Path $directory $archive) -UseBasicParsing
        Invoke-WebRequest "$baseUrl/SHA256SUMS" -OutFile (Join-Path $directory 'SHA256SUMS') -UseBasicParsing

        $line = Get-Content (Join-Path $directory 'SHA256SUMS') | Where-Object { ($_ -split '\s+')[1] -eq $archive }
        if (-not $line) { throw "No checksum published for $archive" }

        $expected = ($line -split '\s+')[0]
        $actual = (Get-FileHash (Join-Path $directory $archive) -Algorithm SHA256).Hash
        if ($expected -ne $actual.ToLower()) { throw "Checksum mismatch for $archive" }

        Expand-Archive (Join-Path $directory $archive) -DestinationPath $directory
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Copy-Item (Join-Path $directory 'kemeter.exe') (Join-Path $installDir 'kemeter.exe') -Force
    }
    finally {
        Remove-Item $directory -Recurse -Force -ErrorAction SilentlyContinue
    }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $installDir) {
        [Environment]::SetEnvironmentVariable('Path', "$userPath;$installDir", 'User')
        $env:Path = "$env:Path;$installDir"
        Write-Host "Added $installDir to your PATH. Open a new terminal to use it everywhere."
    }

    Write-Host "Installed $(& (Join-Path $installDir 'kemeter.exe') --version) in $installDir"
}

Install-Kemeter
