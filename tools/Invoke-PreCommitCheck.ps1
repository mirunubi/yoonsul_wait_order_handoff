<#
.SYNOPSIS
    pre-commit governance check. Called by .git/hooks/pre-commit.

.DESCRIPTION
    Read-only. Runs tools/Check-Governance.ps1 against the STAGED files only,
    so a commit does not pay for a full 2,300-file scan.

    Scope rules:
      * docs/**/*.md that are added/copied/modified/renamed (--diff-filter=ACMR).
        Deletions are not checked.
      * sql/migrations/*.sql that are newly ADDED (--diff-filter=A). This is the
        main reason the hook exists: G15 checks that the workpacket's Stage 7
        human approval is recorded before a migration lands (000701 s10.1).

    Existing violations are not the commit's problem. Check-Governance.ps1 is
    told to report only on the staged paths, while still building the full
    inventory so link/duplicate/registry checks stay accurate.

    Exit code is 0 by default - this warns, it does not block. Set
    GOVERNANCE_STRICT=1 (or pass -Strict) to exit 1 when an ERROR is found.

.PARAMETER Strict
    Exit 1 if any ERROR-severity finding is reported. Also enabled by setting
    the GOVERNANCE_STRICT environment variable to 1.

.NOTES
    Pure ASCII on purpose: Windows PowerShell 5.1 decodes BOM-less script files
    as ANSI and would corrupt any non-ASCII literal. Korean text coming out of
    the scanned documents still prints correctly.
#>

[CmdletBinding()]
param(
    [switch] $Strict
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

if ($env:GOVERNANCE_STRICT -eq '1') { $Strict = $true }

$RepoRoot  = Split-Path -Parent $PSScriptRoot
$CheckerPs = Join-Path $PSScriptRoot 'Check-Governance.ps1'

# The exclusion list is defined once, in tools/GovernanceExclusions.ps1.
$exclusionModule = Join-Path $PSScriptRoot 'GovernanceExclusions.ps1'
if (-not (Test-Path -LiteralPath $exclusionModule)) {
    Write-Output "[governance] SKIPPED - required file not found: $exclusionModule"
    exit 0
}
. $exclusionModule

if (-not (Test-Path -LiteralPath $CheckerPs)) {
    Write-Output "[governance] SKIPPED - required file not found: $CheckerPs"
    exit 0
}

# ---------------------------------------------------------------------------
# Staged file lists (read-only git)
# ---------------------------------------------------------------------------

function Get-GitLines {
    param([string[]] $GitArgs)
    $prev = $ErrorActionPreference
    $out  = $null
    $code = 1
    try {
        $ErrorActionPreference = 'Continue'
        $out  = & git @GitArgs
        $code = $LASTEXITCODE
    }
    catch { $out = $null; $code = 1 }
    finally {
        $ErrorActionPreference = $prev
        $global:LASTEXITCODE = 0
    }
    if ($code -ne 0 -or $null -eq $out) { return @() }
    return @($out)
}

Push-Location $RepoRoot
try {
    $stagedChanged = Get-GitLines @('diff', '--cached', '--name-only', '--diff-filter=ACMR')
    $stagedAdded   = Get-GitLines @('diff', '--cached', '--name-only', '--diff-filter=A')
}
finally { Pop-Location }

$docTargets = @()
foreach ($p in $stagedChanged) {
    $q = ([string]$p).Replace('\', '/').Trim()
    if ($q -notmatch '(?i)^docs/.+\.md$') { continue }
    $relDocs = $q.Substring(5)
    if ($null -ne (Test-GovExcluded $relDocs)) { continue }
    $docTargets += $q
}

$sqlTargets = @()
foreach ($p in $stagedAdded) {
    $q = ([string]$p).Replace('\', '/').Trim()
    if ($q -match '(?i)^sql/migrations/[^/]+\.sql$') { $sqlTargets += $q }
}

$targets = @($docTargets) + @($sqlTargets)

if ($targets.Count -eq 0) {
    Write-Output '[governance] 0 files checked, no new findings'
    Write-Output '[governance] to bypass: git commit --no-verify'
    exit 0
}

# ---------------------------------------------------------------------------
# Run the checker restricted to those paths
# ---------------------------------------------------------------------------

$outLines = @()
try {
    $outLines = @(& $CheckerPs -File $targets -Top 10)
}
catch {
    Write-Output ('[governance] checker failed: {0}' -f $_.Exception.Message)
    Write-Output '[governance] to bypass: git commit --no-verify'
    exit 0
}
$global:LASTEXITCODE = 0

$nError = 0; $nWarn = 0; $nReview = 0
foreach ($l in $outLines) {
    if     ($l -match '^\s{2}ERROR\s+(\d+)\s')  { $nError  = [int]$Matches[1] }
    elseif ($l -match '^\s{2}WARN\s+(\d+)\s')   { $nWarn   = [int]$Matches[1] }
    elseif ($l -match '^\s{2}REVIEW\s+(\d+)\s') { $nReview = [int]$Matches[1] }
}
$nTotal = $nError + $nWarn + $nReview

if ($nTotal -eq 0) {
    Write-Output ('[governance] {0} files checked, no new findings' -f $targets.Count)
    Write-Output '[governance] to bypass: git commit --no-verify'
    exit 0
}

# ---------------------------------------------------------------------------
# Print the finding blocks only - drop the repo-wide coverage sections
# ---------------------------------------------------------------------------

$startIdx = -1
$endIdx   = $outLines.Count
for ($i = 0; $i -lt $outLines.Count; $i++) {
    if ($startIdx -lt 0 -and $outLines[$i] -match '^\s\[[ABCD]\]\s') { $startIdx = [Math]::Max(0, $i - 1) }
    if ($outLines[$i] -match '^\sRANGE_UNDETERMINED\s') { $endIdx = [Math]::Max(0, $i - 2); break }
}

Write-Output ''
Write-Output ('[governance] {0} staged file(s) checked' -f $targets.Count)

if ($startIdx -ge 0 -and $endIdx -gt $startIdx) {
    # emit band sections, skipping the ones reported as clean
    $block = @()
    $blockIsClean = $false
    for ($i = $startIdx; $i -lt $endIdx; $i++) {
        $line = $outLines[$i]
        if ($line -match '^\s\[[ABCD]\]\s') {
            if ($block.Count -gt 0 -and -not $blockIsClean) { $block | ForEach-Object { Write-Output $_ } }
            $block = @()
            $blockIsClean = $false
        }
        if ($line -match '^\s+\(clean\)\s*$') { $blockIsClean = $true }
        $block += $line
    }
    if ($block.Count -gt 0 -and -not $blockIsClean) { $block | ForEach-Object { Write-Output $_ } }
}

# ---------------------------------------------------------------------------
# Stage 7 gate is the headline case - make it impossible to miss
# ---------------------------------------------------------------------------

# Match only a finding's detail line - the token alone on an indented line.
# A loose match would also hit the "CONTRACT_NOT_FOUND   0" coverage counter.
$g15Hits = @($outLines | Where-Object { $_ -match '^\s{6}(MIGRATION_WITHOUT_APPROVAL|CONTRACT_NOT_FOUND)\s*$' })
if ($g15Hits.Count -gt 0) {
    $bang = '!' * 78
    Write-Output ''
    Write-Output $bang
    Write-Output '  STAGE 7 GATE (G15)'
    Write-Output '  A migration is being committed while its workpacket has no recorded'
    Write-Output '  human approval. 000701 s10.1 makes Stage 7 the gate between design and'
    Write-Output '  implementation; 600020 records what happened the last time it was skipped.'
    Write-Output $bang
}

Write-Output ''
Write-Output ('[governance] {0} files checked: {1} ERROR, {2} WARN, {3} REVIEW' -f $targets.Count, $nError, $nWarn, $nReview)

$exitCode = 0
if ($Strict -and $nError -gt 0) {
    Write-Output '[governance] GOVERNANCE_STRICT is set and ERROR findings exist - blocking commit'
    $exitCode = 1
}
else {
    Write-Output '[governance] warning only - commit is not blocked (set GOVERNANCE_STRICT=1 to block)'
}
Write-Output '[governance] to bypass: git commit --no-verify'

exit $exitCode
