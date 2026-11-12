<#
.SYNOPSIS
    Removes the Hollow Knight Lithuanian translation mod.

.DESCRIPTION
    Restores the original game files from the *.orig backups that install.ps1
    created.  Files without a backup are left alone.

.PARAMETER Path
    Optional.  The Hollow Knight installation folder.  When it is not given the
    script looks through the Steam library folders for the game.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

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

function Get-SteamRoots {
    $roots = New-Object System.Collections.Generic.List[string]

    foreach ($key in @(
            'HKCU:\Software\Valve\Steam',
            'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
            'HKLM:\SOFTWARE\Valve\Steam')) {
        if (Test-Path $key) {
            $p = (Get-ItemProperty -Path $key -ErrorAction SilentlyContinue).SteamPath
            if ($p -and (Test-Path $p)) { $roots.Add($p) }
        }
    }

    foreach ($p in @(
            "${env:ProgramFiles(x86)}\Steam",
            "$env:ProgramFiles\Steam",
            "$env:ProgramW6432\Steam",
            "$env:LOCALAPPDATA\Steam",
            'C:\Program Files (x86)\Steam',
            'C:\Program Files\Steam')) {
        if ($p -and (Test-Path $p)) { $roots.Add($p) }
    }

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

Write-Host 'Hollow Knight - Lithuanian translation (uninstall)' -ForegroundColor Green
Write-Host '==========================================='

$running = Get-Process -Name 'hollow_knight' -ErrorAction SilentlyContinue
if ($running) {
    Write-Fail 'Hollow Knight is running. Close the game and run the uninstaller again.'
}

Write-Section 'Looking for Hollow Knight'
$game = Find-Game
if (-not $game) {
    Write-Host 'Could not find Hollow Knight in your Steam libraries.'
    Write-Host 'Run the uninstaller again with the installation folder, for example:'
    Write-Host '  uninstall.bat "D:\SteamLibrary\steamapps\common\Hollow Knight"'
    exit 1
}
Write-Host "  $game"

$data = Join-Path $game 'hollow_knight_Data'

Write-Section 'Restoring the original files'
foreach ($rel in $GameFiles) {
    $to = Join-Path $data $rel
    $backup = "$to.orig"
    if (Test-Path $backup) {
        Move-Item -Path $backup -Destination $to -Force
        Write-Host "  restored  $rel"
    }
    elseif (Test-Path $to) {
        Write-Host "  no backup for $rel, leaving it alone"
    }
}

Write-Section 'Done'
Write-Host 'The Lithuanian translation has been removed.'
Write-Host ''
