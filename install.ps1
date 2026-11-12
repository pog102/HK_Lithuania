<#
.SYNOPSIS
    Installs the Hollow Knight Lithuanian translation mod.

.DESCRIPTION
    Copies the four patched game files into the Hollow Knight installation and
    keeps the originals as *.orig so the mod can be removed again.

.PARAMETER Path
    Optional.  The Hollow Knight installation folder.  When it is not given the
    script looks through the Steam library folders for the game.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File install.ps1
    powershell -ExecutionPolicy Bypass -File install.ps1 -Path "D:\SteamLibrary\steamapps\common\Hollow Knight"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

# The files the mod replaces, relative to hollow_knight_Data.
$GameFiles = @(
    'resources.assets',
    'sharedassets0.assets',
    'globalgamemanagers',
    'Managed\Assembly-CSharp.dll'
)

function Write-Section($text) {
    Write-Host ''
    Write-Host "== $text" -ForegroundColor Cyan
}

function Write-Fail($text) {
    Write-Host ''
    Write-Host "!! $text" -ForegroundColor Red
    exit 1
}

# --- find the Steam installation ---------------------------------------------
function Get-SteamRoots {
    $roots = New-Object System.Collections.Generic.List[string]

    # the registry knows where Steam lives
    foreach ($key in @(
            'HKCU:\Software\Valve\Steam',
            'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
            'HKLM:\SOFTWARE\Valve\Steam')) {
        if (Test-Path $key) {
            $p = (Get-ItemProperty -Path $key -ErrorAction SilentlyContinue).SteamPath
            if ($p -and (Test-Path $p)) { $roots.Add($p) }
        }
    }

    # ...and the usual install locations
    foreach ($p in @(
            "${env:ProgramFiles(x86)}\Steam",
            "$env:ProgramFiles\Steam",
            "$env:ProgramW6432\Steam",
            "$env:LOCALAPPDATA\Steam",
            'C:\Program Files (x86)\Steam',
            'C:\Program Files\Steam')) {
        if ($p -and (Test-Path $p)) { $roots.Add($p) }
    }

    # every Steam library may hold the game, so read libraryfolders.vdf
    foreach ($root in @($roots)) {
        $vdf = Join-Path $root 'steamapps\libraryfolders.vdf'
        if (-not (Test-Path $vdf)) { continue }
        foreach ($line in Get-Content $vdf -ErrorAction SilentlyContinue) {
            if ($line -match '"path"\s+"([^"]+)"') {
                $lib = $Matches[1] -replace '\\\\', '\'
                if (Test-Path $lib) { $roots.Add($lib) }
            }
        }
    }

    return $roots
}

function Find-Game {
    if ($Path) {
        if (-not (Test-Path (Join-Path $Path 'hollow_knight_Data'))) {
            Write-Fail "'$Path' does not look like a Hollow Knight installation."
        }
        return (Resolve-Path $Path).Path
    }

    foreach ($root in Get-SteamRoots) {
        $candidate = Join-Path $root 'steamapps\common\Hollow Knight'
        if (Test-Path (Join-Path $candidate 'hollow_knight_Data')) {
            return (Resolve-Path $candidate).Path
        }
    }
    return $null
}

# --- main ---------------------------------------------------------------------
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $here 'files\hollow_knight_Data'

Write-Host 'Hollow Knight - Lithuanian translation' -ForegroundColor Green
Write-Host '============================='

if (-not (Test-Path $src)) {
    Write-Fail "The patched game files are missing ($src)."
}

Write-Section 'Looking for Hollow Knight'
$game = Find-Game
if (-not $game) {
    Write-Host 'Could not find Hollow Knight in your Steam libraries.'
    Write-Host ''
    Write-Host 'Run the installer again with the installation folder, for example:'
    Write-Host '  install.bat "D:\SteamLibrary\steamapps\common\Hollow Knight"'
    exit 1
}
Write-Host "  $game"

# the game must not be running, otherwise the files are locked
$running = Get-Process -Name 'hollow_knight' -ErrorAction SilentlyContinue
if ($running) {
    Write-Fail 'Hollow Knight is running. Close the game and run the installer again.'
}

$data = Join-Path $game 'hollow_knight_Data'

Write-Section 'Installing'
foreach ($rel in $GameFiles) {
    $from = Join-Path $src $rel
    $to = Join-Path $data $rel

    if (-not (Test-Path $from)) {
        Write-Fail "The patched file is missing from the package: $rel"
    }
    if (-not (Test-Path $to)) {
        Write-Fail "The game file is missing: $to"
    }

    # keep the original the first time, so the mod can be uninstalled
    $backup = "$to.orig"
    if (-not (Test-Path $backup)) {
        Copy-Item -Path $to -Destination $backup -Force
        Write-Host "  backed up  $rel"
    }

    # Steam sometimes leaves the game files read-only
    if (Test-Path $to) { Set-ItemProperty -Path $to -Name IsReadOnly -Value $false }

    Copy-Item -Path $from -Destination $to -Force
    Write-Host "  installed  $rel"
}

Write-Section 'Done'
Write-Host 'Start the game and pick "Lietuviu" in Options -> Game Options -> Language.'
Write-Host 'To remove the mod again, run uninstall.bat.'
Write-Host ''
Write-Host 'Note: Steam'"'"'s "Verify integrity of game files" will restore the' -ForegroundColor DarkGray
Write-Host 'originals and remove the translation.' -ForegroundColor DarkGray
Write-Host ''
