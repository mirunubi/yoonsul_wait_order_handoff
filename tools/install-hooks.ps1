<#
.SYNOPSIS
    Install the governance git hooks into this clone's .git/hooks/.

.DESCRIPTION
    .git/hooks/ is not tracked by git, so hooks vanish on a fresh clone. The
    source of truth lives in tools/hooks/ (which IS tracked) and this script
    copies it into place.

    Run after cloning, or after changing tools/hooks/pre-commit:

        powershell -NoProfile -ExecutionPolicy Bypass -File tools/install-hooks.ps1

.PARAMETER Force
    Overwrite an existing hook without prompting.

.PARAMETER WhatIfOnly
    Report what would be installed and exit without writing anything.

.NOTES
    Pure ASCII on purpose (Windows PowerShell 5.1 / BOM-less script decoding).
    Hook files are copied byte-for-byte so their LF line endings survive - sh
    will not run a CRLF script cleanly.
#>

[CmdletBinding()]
param(
    [switch] $Force,
    [switch] $WhatIfOnly
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SrcDir   = Join-Path $PSScriptRoot 'hooks'

if (-not (Test-Path -LiteralPath $SrcDir -PathType Container)) {
    throw "hook source directory not found: $SrcDir"
}

# Resolve the real git directory. Usually <repo>/.git, but in a worktree or a
# submodule .git is a FILE containing "gitdir: <path>".
$dotGit = Join-Path $RepoRoot '.git'
$gitDir = $null
if (Test-Path -LiteralPath $dotGit -PathType Container) {
    $gitDir = $dotGit
}
elseif (Test-Path -LiteralPath $dotGit -PathType Leaf) {
    $firstLine = (Get-Content -LiteralPath $dotGit -TotalCount 1)
    if ($firstLine -match '^gitdir:\s*(.+)$') {
        $candidate = $Matches[1].Trim()
        if (-not [System.IO.Path]::IsPathRooted($candidate)) {
            $candidate = Join-Path $RepoRoot $candidate
        }
        $gitDir = (Resolve-Path -LiteralPath $candidate).ProviderPath
    }
}
if ($null -eq $gitDir) {
    throw "could not locate the git directory from $dotGit"
}

$HookDir = Join-Path $gitDir 'hooks'
if (-not (Test-Path -LiteralPath $HookDir -PathType Container)) {
    if ($WhatIfOnly) {
        Write-Output "would create: $HookDir"
    }
    else {
        $null = New-Item -ItemType Directory -Path $HookDir -Force
    }
}

Write-Output ('repo      : {0}' -f $RepoRoot)
Write-Output ('git dir   : {0}' -f $gitDir)
Write-Output ('hook dir  : {0}' -f $HookDir)
Write-Output ('source    : {0}' -f $SrcDir)
Write-Output ''

$installed = 0
$skipped   = 0

foreach ($src in @(Get-ChildItem -LiteralPath $SrcDir -File | Sort-Object Name)) {
    $dest = Join-Path $HookDir $src.Name

    if ($WhatIfOnly) {
        Write-Output ('would install: {0} -> {1}' -f $src.Name, $dest)
        continue
    }

    if ((Test-Path -LiteralPath $dest) -and -not $Force) {
        $existing = [System.IO.File]::ReadAllBytes($dest)
        $incoming = [System.IO.File]::ReadAllBytes($src.FullName)
        $same = ($existing.Length -eq $incoming.Length)
        if ($same) {
            for ($i = 0; $i -lt $existing.Length; $i++) {
                if ($existing[$i] -ne $incoming[$i]) { $same = $false; break }
            }
        }
        if ($same) {
            Write-Output ('unchanged    : {0}' -f $src.Name)
            $skipped++
            continue
        }
        Write-Output ('SKIPPED      : {0} already exists and differs. Re-run with -Force to overwrite.' -f $src.Name)
        $skipped++
        continue
    }

    # byte-for-byte copy so LF endings survive
    Copy-Item -LiteralPath $src.FullName -Destination $dest -Force
    Write-Output ('installed    : {0} -> {1}' -f $src.Name, $dest)
    $installed++
}

if (-not $WhatIfOnly) {
    Write-Output ''
    Write-Output ('{0} installed, {1} skipped.' -f $installed, $skipped)
    Write-Output ''
    Write-Output 'The pre-commit hook warns only; it does not block a commit.'
    Write-Output 'Set GOVERNANCE_STRICT=1 to make ERROR findings block.'
    Write-Output 'Bypass a single commit with: git commit --no-verify'
}
