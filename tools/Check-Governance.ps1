<#
.SYNOPSIS
    Mechanical governance conformance checker for docs/.

.DESCRIPTION
    Read-only. Never writes, renames, stages or commits anything. Exit code is
    always 0 - this is a warning report, not a CI gate.

    Every check is derived from a written rule in:
      docs/000001_Md_Rules.md
      docs/000002_Naming_Rules.md
      docs/000005_Index_Document_Number.md   (registry integrity)
      docs/000007_Map_Full_Directory.md      (directory map integrity)

    All bands are checked equally. The 600000_implementation_lifecycle band
    carries a 2026-08-10 AUTHORITY SUSPENDED ruling, but that ruling concerns
    design authority, not document-format conformance, so 600000 is scanned and
    reported like every other band.

    Findings carry one of three severities:
      ERROR   a confirmed rule violation
      WARN    needs review; a violation cannot be asserted mechanically
      REVIEW  list only; this checker makes no judgement at all

    Output is grouped into four band sections:
      [A] docs root and the 000000-099999 bands
      [B] 600000_implementation_lifecycle band  (600000-699999)
      [C] 700000 and above
      [D] everything else (no numeric prefix, or 100000-599999)

.PARAMETER Root
    docs/ directory to scan. Defaults to <repo>/docs relative to this script.

.PARAMETER Band
    Restrict the scan to one band. Accepts a section letter (A, B, C, D) or a
    numeric top-level folder prefix (e.g. 600000). Omit to scan everything.

.PARAMETER Top
    Per-check display cap. Default 50. Use 0 for unlimited.
    The summary always reports FULL counts regardless of this cap.

.PARAMETER IncludeExcluded
    Also scan the paths that are excluded by default (see Exclusions below).

.PARAMETER File
    Restrict reporting to the given paths, e.g. a staged-file list from a
    pre-commit hook. Accepts repo-relative ("docs/x.md", "sql/migrations/y.sql"),
    docs-relative, or absolute paths.

    The full inventory is still built, so existence-based checks (G11 stale
    entries, G13 link targets) never produce false "missing target" findings,
    and G08 still detects a duplicate against a file that is not staged.

    Repository-wide checks that are not about individual files - G06, G07, G12,
    and the G11 stale-entry sweep - are skipped while -File is in effect,
    because they would report findings unrelated to the given paths.

    G15 runs only for sql/migrations/*.sql paths present in the list.

.PARAMETER StrictStage7
    Escalate G15 findings from WARN to ERROR.

    G15 checks the workpacket header required by 000701 s6.11.1
    (Migration Workpacket Header Rule, 2026-08-11). The rule is
    not retroactive: the 167 migrations predating it carry no
    header and are reported as NO_HEADER, not as violations,
    because s14.5 forbids editing them.
    Runs as WARN by default so that existing findings do not block
    commits. Use -StrictStage7 or GOVERNANCE_STRICT=1 to escalate.

.EXAMPLE
    powershell -File tools\Check-Governance.ps1

.EXAMPLE
    powershell -File tools\Check-Governance.ps1 -Band 600000 -Top 0

.NOTES
    This source file is deliberately pure ASCII. Windows PowerShell 5.1 decodes
    BOM-less script files as ANSI, which would corrupt any non-ASCII literal in
    the source. Korean text read out of the scanned documents still prints
    correctly because file reads decode UTF-8 explicitly and the console output
    encoding is set to UTF-8 below.
#>

[CmdletBinding()]
param(
    [string] $Root,
    [string] $Band,
    [int]      $Top = 50,
    [switch]   $IncludeExcluded,
    [switch]   $StrictStage7,
    [string[]] $File
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

if (-not $Root -or $Root.Length -eq 0) {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $Root = Join-Path $repoRoot 'docs'
}
if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    throw "docs root not found: $Root"
}
$Root = (Resolve-Path -LiteralPath $Root).ProviderPath.TrimEnd('\')
$RepoRoot = Split-Path -Parent $Root
$MigrationsDir = Join-Path $RepoRoot 'sql\migrations'

# ---------------------------------------------------------------------------
# Korean literals used by G15, assembled from code points so this source file
# stays pure ASCII. PowerShell 5.1 decodes BOM-less scripts as ANSI and would
# corrupt literal Hangul.
# ---------------------------------------------------------------------------

$KoWorkpacket = [string]([char]0xC6CC) + [string]([char]0xD06C) + [string]([char]0xD328) + [string]([char]0xD0B7)  # workpacket
$KoPending    = [string]([char]0xB300) + [string]([char]0xAE30)                                                   # pending / waiting
$KoNotStarted = [string]([char]0xBBF8) + [string]([char]0xCC29) + [string]([char]0xC218)                          # not started
$KoApproved   = [string]([char]0xC2B9) + [string]([char]0xC778)                                                   # approved

# ---------------------------------------------------------------------------
# -File restriction sets
# ---------------------------------------------------------------------------

$RestrictDocs       = $null
$RestrictMigrations = $null
if ($File -and $File.Count -gt 0) {
    $RestrictDocs       = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $RestrictMigrations = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($fp in $File) {
        if ($null -eq $fp) { continue }
        $p = $fp.Replace('\', '/').Trim()
        if ($p.Length -eq 0) { continue }
        if ($p -match '(?i)(^|/)sql/migrations/([^/]+\.sql)$') {
            $null = $RestrictMigrations.Add($Matches[2])
            continue
        }
        # strip an absolute prefix down to the docs-relative form
        $rootFwd = $Root.Replace('\', '/')
        if ($p.StartsWith($rootFwd, [System.StringComparison]::OrdinalIgnoreCase)) {
            $p = $p.Substring($rootFwd.Length).TrimStart('/')
        }
        elseif ($p -match '(?i)^docs/') {
            $p = $p.Substring(5)
        }
        if ($p.Length -gt 0) { $null = $RestrictDocs.Add($p) }
    }
}

# ---------------------------------------------------------------------------
# Exclusions
#
# These paths are not governed by the naming/index rules in the same way as the
# live documentation spine, so scanning them produces noise rather than signal.
# -IncludeExcluded turns the whole list off.
# ---------------------------------------------------------------------------

# The rule list itself lives in tools/GovernanceExclusions.ps1 so that this
# script and tools/Invoke-PreCommitCheck.ps1 share ONE definition.
$exclusionModule = Join-Path $PSScriptRoot 'GovernanceExclusions.ps1'
if (-not (Test-Path -LiteralPath $exclusionModule)) {
    throw "required file not found: $exclusionModule"
}
. $exclusionModule

function Get-ExclusionReason {
    param([string] $RelPath)
    if ($IncludeExcluded) { return $null }
    return (Test-GovExcluded $RelPath)
}

# 990000 keeps its G14 exemption even under -IncludeExcluded: the Group C files
# under 990000_legacy_quarantine/604000_workpackets/ were 600000-band artifacts
# that moved during quarantine. The path changed; the DocumentType use did not
# become wrong.
$G14ExemptPattern = '^990000_legacy_quarantine(/|$)'

# ---------------------------------------------------------------------------
# Rule data (docs/000002_Naming_Rules.md section 1.2)
# ---------------------------------------------------------------------------

$GroupA = @('Readme','Index','Guide','Policy','Spec','Implementation','Boundary',
            'Governance','Diagram','Map','Matrix','Register','Template','Assessment')
$GroupB = @('Plan','Checklist','SOP','Runbook','Report','Evidence','Audit','ADR',
            'WorkPackage','Closeout')
# Group C is declared "Implementation Lifecycle Only (600000 band)".
# ImpactScope comes from 000001 section 5.4.3; Approval from 000001 section 5.4.1.
$GroupC = @('Overview','Logic','TestPlan','ChangeContract','Approval','Module',
            'Verification','NavigationMap','ImpactScope')

$ApprovedTypes = $GroupA + $GroupB + $GroupC

# 000002 section 1.2.2 / 1.2.3: prefix-less lifecycle artifacts are sanctioned
# only inside implementation_evidence/<change_id>/ and for NavigationMap.md.
$PrefixExemptDirs  = @('implementation_evidence')
$PrefixExemptNames = @('NavigationMap.md')

# G09 similarity floor. Below this, the H1 is reported as WARN.
$H1SimilarityFloor = 0.60

$CheckCatalog = [ordered]@{
    'G01' = @{ Sev = 'ERROR';  Text = 'Filename has no valid six-digit numeric prefix    (000002 s1, s1.1)' }
    'G02' = @{ Sev = 'ERROR';  Text = 'DocumentType missing or not an approved value     (000002 s1.2)' }
    'G03' = @{ Sev = 'ERROR';  Text = 'Filename uses unsafe or non-conforming characters (000002 s1.3, s1.4)' }
    'G04' = @{ Sev = 'REVIEW'; Text = 'Title-less 600xxx lifecycle filename - LIST ONLY  (000002 s1.2)' }
    'G05' = @{ Sev = 'ERROR';  Text = 'Document number outside its folder-owned range    (000002 s2.1)' }
    'G06' = @{ Sev = 'ERROR';  Text = 'Folder under docs/ has no numeric prefix          (000002 s2)' }
    'G07' = @{ Sev = 'ERROR';  Text = 'Governed folder missing Readme / Readme misnumber (000001 s5.2 / 000002 s5)' }
    'G08' = @{ Sev = 'ERROR';  Text = 'Duplicate document number across docs/            (000002 s1)' }
    'G09' = @{ Sev = 'MIXED';  Text = 'H1 heading missing or unlike the filename         (000001 s2 / 000002 s6)' }
    'G10' = @{ Sev = 'ERROR';  Text = 'Encoding defect: BOM, invalid UTF-8, or mixed EOL (000001 s1)' }
    'G11' = @{ Sev = 'ERROR';  Text = 'Registry drift against 000005_Index_Document_Num  (000001 s5, s5.1)' }
    'G12' = @{ Sev = 'WARN';   Text = 'Directory-map drift against 000007 (name-level)   (000001 s5, s5.1)' }
    'G13' = @{ Sev = 'ERROR';  Text = 'Relative markdown link points at a missing file   (000001 s5.9)' }
    'G14' = @{ Sev = 'ERROR';  Text = 'Group C DocumentType used outside the 600000 band (000002 s1.2)' }
    'G15' = @{ Sev = 'WARN';   Text = 'Stage 7 gate - migration without approval (000701 s10, s6.11.1)' }
}
if ($StrictStage7) { $CheckCatalog['G15'].Sev = 'ERROR' }

$BandTitles = [ordered]@{
    'A' = '[A] docs root and 000000-099999 bands'
    'B' = '[B] 600000_implementation_lifecycle band (600000-699999)'
    'C' = '[C] 700000 and above'
    'D' = '[D] other (no numeric prefix, or 100000-599999)'
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Get-RelPath {
    param([string] $FullPath)
    $p = $FullPath
    if ($p.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        $p = $p.Substring($Root.Length).TrimStart('\', '/')
    }
    return $p.Replace('\', '/')
}

function Get-TopSegment {
    param([string] $RelPath)
    $i = $RelPath.IndexOf('/')
    if ($i -lt 0) { return '' }
    return $RelPath.Substring(0, $i)
}

function Get-BandLetter {
    param([string] $RelPath)
    $seg = Get-TopSegment $RelPath
    if ($seg.Length -eq 0) { return 'A' }          # directly in docs/
    if ($seg -match '^(\d{6})') {
        $n = [int]$Matches[1]
        if ($n -lt 100000) { return 'A' }
        if ($n -ge 600000 -and $n -lt 700000) { return 'B' }
        if ($n -ge 700000) { return 'C' }
        return 'D'                                  # 100000-599999
    }
    return 'D'
}

# Normalize a filename or H1 for meaning comparison (000002 s6 says the internal
# title must match the filename MEANING, not the literal string).
function Get-NormalizedTitle {
    param([string] $Value)
    $v = $Value
    $v = $v -replace '(?i)\.md$', ''
    $v = $v -replace '[^A-Za-z0-9]', ''
    return $v.ToLowerInvariant()
}

# Longest common subsequence length, used as the "common portion" measure.
function Get-LcsLength {
    param([string] $A, [string] $B)
    $la = $A.Length; $lb = $B.Length
    if ($la -eq 0 -or $lb -eq 0) { return 0 }
    $prev = New-Object 'int[]' ($lb + 1)
    $cur  = New-Object 'int[]' ($lb + 1)
    for ($i = 1; $i -le $la; $i++) {
        $ca = $A[$i - 1]
        for ($j = 1; $j -le $lb; $j++) {
            if ($ca -eq $B[$j - 1]) { $cur[$j] = $prev[$j - 1] + 1 }
            elseif ($prev[$j] -ge $cur[$j - 1]) { $cur[$j] = $prev[$j] }
            else { $cur[$j] = $cur[$j - 1] }
        }
        $tmp = $prev; $prev = $cur; $cur = $tmp
        for ($j = 0; $j -le $lb; $j++) { $cur[$j] = 0 }
    }
    return $prev[$lb]
}

function Get-TitleSimilarity {
    param([string] $A, [string] $B)
    $na = Get-NormalizedTitle $A
    $nb = Get-NormalizedTitle $B
    if ($na.Length -eq 0 -and $nb.Length -eq 0) { return 1.0 }
    $longest = [Math]::Max($na.Length, $nb.Length)
    if ($longest -eq 0) { return 1.0 }
    $lcs = Get-LcsLength $na $nb
    return ([double]$lcs / [double]$longest)
}

# -Band filter -------------------------------------------------------------

$FilterLetter = $null
$FilterNumber = $null
if ($Band -and $Band.Length -gt 0) {
    if ($Band -match '^[A-Da-d]$') {
        $FilterLetter = $Band.ToUpper()
    }
    elseif ($Band -match '^\d+$') {
        $FilterNumber = [int]$Band
    }
    else {
        throw "-Band must be a section letter (A/B/C/D) or a numeric folder prefix (e.g. 600000). Got: $Band"
    }
}

function Test-InScope {
    param([string] $RelPath)
    if ($null -ne $FilterLetter) {
        return ((Get-BandLetter $RelPath) -eq $FilterLetter)
    }
    if ($null -ne $FilterNumber) {
        $seg = Get-TopSegment $RelPath
        if ($seg.Length -eq 0) { return ($FilterNumber -lt 100) }
        if ($seg -match '^(\d{6})') { return ([int]$Matches[1] -eq $FilterNumber) }
        return $false
    }
    return $true
}

# Findings -----------------------------------------------------------------

$Findings = New-Object System.Collections.ArrayList

function Add-Finding {
    param(
        [string] $CheckId,
        [string] $RelPath,
        [string] $Detail,
        [string] $Severity,
        [string] $BandOverride,
        [string] $ScopePath
    )
    # G15 findings live under sql/, not docs/, so band and -Band scoping cannot
    # be derived from the displayed path. Callers pass ScopePath - the governing
    # docs-relative path, e.g. the ChangeContract - so both work normally. When
    # even that is unavailable, BandOverride supplies the letter alone.
    if ($ScopePath -and $ScopePath.Length -gt 0) {
        if (-not (Test-InScope $ScopePath)) { return }
        $bandLetter = Get-BandLetter $ScopePath
    }
    elseif ($BandOverride -and $BandOverride.Length -gt 0) {
        $bandLetter = $BandOverride
        if ($null -ne $FilterLetter -and $bandLetter -ne $FilterLetter) { return }
        # a numeric -Band filter cannot be evaluated without a docs path
        if ($null -ne $FilterNumber) { return }
    }
    else {
        if (-not (Test-InScope $RelPath)) { return }
        $bandLetter = Get-BandLetter $RelPath
    }

    if (-not $Severity -or $Severity.Length -eq 0) {
        $Severity = $CheckCatalog[$CheckId].Sev
    }
    $null = $Findings.Add([pscustomobject]@{
        Check    = $CheckId
        Severity = $Severity
        Band     = $bandLetter
        Path     = $RelPath
        Detail   = $Detail
    })
}

# ---------------------------------------------------------------------------
# Collect the file and folder inventory
# ---------------------------------------------------------------------------

Write-Output "Scanning $Root ..."

$allFiles = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue)
$allDirsRaw = @(Get-ChildItem -LiteralPath $Root -Recurse -Directory -ErrorAction SilentlyContinue)

# Unfiltered sets. Existence checks (G11 stale entries, G13 link targets, G12
# folder names) must use these, otherwise excluding a path would manufacture
# false "missing target" findings.
$allFileRelSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($f in $allFiles) { $null = $allFileRelSet.Add((Get-RelPath $f.FullName)) }
$allDirNameSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
foreach ($dir in $allDirsRaw) { $null = $allDirNameSet.Add($dir.Name) }

$allDocs = @()
$excludedFileCount = 0
$excludedReasonTally = @{}

foreach ($f in $allFiles) {
    $rel = Get-RelPath $f.FullName
    $why = Get-ExclusionReason $rel
    if ($null -ne $why) {
        $excludedFileCount++
        if ($excludedReasonTally.ContainsKey($why)) { $excludedReasonTally[$why]++ }
        else { $excludedReasonTally[$why] = 1 }
        continue
    }
    # NOTE: do not name this $top - it would collide with the [int]$Top parameter
    # (PowerShell variable names are case-insensitive) and fail type conversion.
    $topSeg = Get-TopSegment $rel
    $num = $null
    $dt  = $null
    if ($f.Name -match '^(\d{6})_([A-Za-z][A-Za-z0-9]*)') {
        $num = [int]$Matches[1]
        $dt  = $Matches[2]
    }
    elseif ($f.Name -match '^(\d{6})') {
        $num = [int]$Matches[1]
    }
    $allDocs += [pscustomobject]@{
        Full = $f.FullName
        Name = $f.Name
        Rel  = $rel
        Top  = $topSeg
        Dir  = (Get-RelPath $f.DirectoryName)
        Num  = $num
        Type = $dt
    }
}

# $allDocs = everything in scope. $docs = what this run reports on.
if ($null -ne $RestrictDocs) {
    $docs = @($allDocs | Where-Object { $RestrictDocs.Contains($_.Rel) })
}
else {
    $docs = $allDocs
}

$allDirs = @()
$excludedDirCount = 0
foreach ($dir in $allDirsRaw) {
    $rel = Get-RelPath $dir.FullName
    if ($null -ne (Get-ExclusionReason $rel)) { $excludedDirCount++; continue }
    $allDirs += $dir
}

if ($null -ne $RestrictDocs) {
    Write-Output ("Restricted by -File: reporting on {0} of {1} in-scope markdown files." -f $docs.Count, $allDocs.Count)
}
Write-Output ("Found {0} markdown files in scope, {1} directories in scope." -f $allDocs.Count, $allDirs.Count)
if (-not $IncludeExcluded) {
    Write-Output ("Excluded from scan: {0} files, {1} directories (-IncludeExcluded to scan them)." -f $excludedFileCount, $excludedDirCount)
}
Write-Output ''

# ---------------------------------------------------------------------------
# G01 / G02 / G03 / G14 - filename conformance
# ---------------------------------------------------------------------------

foreach ($d in $docs) {
    $segments = $d.Rel.Split('/')
    $exemptDir = $false
    foreach ($ex in $PrefixExemptDirs) {
        if ($segments -contains $ex) { $exemptDir = $true }
    }
    $exemptName = ($PrefixExemptNames -contains $d.Name)

    # --- G01 numeric prefix ---
    if ($d.Name -notmatch '^\d{6}_') {
        if (-not $exemptDir -and -not $exemptName) {
            $why = 'no six-digit prefix'
            if ($d.Name -match '^(\d{4})_')        { $why = 'four-digit prefix (000002 s1: not allowed)' }
            elseif ($d.Name -match '^(\d{5})_')    { $why = 'five-digit prefix (migration target)' }
            elseif ($d.Name -match '^(\d{7,})_')   { $why = 'more than six digits' }
            Add-Finding 'G01' $d.Rel $why
        }
    }

    # --- G02 DocumentType ---
    if ($d.Name -match '^\d{6}_') {
        if ($null -eq $d.Type) {
            Add-Finding 'G02' $d.Rel 'no DocumentType token after the numeric prefix'
        }
        elseif ($ApprovedTypes -notcontains $d.Type) {
            Add-Finding 'G02' $d.Rel ("DocumentType '{0}' is not in the approved list" -f $d.Type)
        }
    }

    # --- G03 character safety ---
    $bad = @()
    if ($d.Name -match '\s')                { $bad += 'space' }
    if ($d.Name -match '[^\x20-\x7E]')      { $bad += 'non-ASCII' }
    if ($d.Name -match '[()]')              { $bad += 'parenthesis' }
    if ($d.Name -match ',')                 { $bad += 'comma' }
    if ($d.Name -match ':')                 { $bad += 'colon' }
    if ($d.Name -match '-')                 { $bad += 'hyphen (kebab-case not adopted)' }
    if ($d.Name -cnotmatch '\.md$')         { $bad += 'extension is not lowercase .md' }
    if ($bad.Count -gt 0) {
        Add-Finding 'G03' $d.Rel ($bad -join ', ')
    }

    # --- G14 Group C outside the 600000 band ---
    if ($null -ne $d.Type -and $GroupC -contains $d.Type) {
        $g14Exempt = ($d.Rel -match $G14ExemptPattern)
        if ((Get-BandLetter $d.Rel) -ne 'B' -and -not $exemptDir -and -not $exemptName -and -not $g14Exempt) {
            Add-Finding 'G14' $d.Rel ("Group C DocumentType '{0}' outside 600000 band" -f $d.Type)
        }
    }
}

# ---------------------------------------------------------------------------
# G04 - title-less 600xxx lifecycle filenames  (REVIEW, list only)
#
# No date-based grandfathering. The 2026-07-14 cutoff previously used here was
# evaluated against git add dates, which this repository's rename waves make
# unreliable, and the checker was asserting a verdict on data it had already
# footnoted as untrustworthy. This check now only lists the filenames.
# ---------------------------------------------------------------------------

foreach ($d in $docs) {
    if ($d.Name -match '^(6\d{5})_([A-Za-z][A-Za-z0-9]*)\.md$') {
        Add-Finding 'G04' $d.Rel ("no title component after DocumentType '{0}'" -f $Matches[2])
    }
}

# ---------------------------------------------------------------------------
# G05 - folder-owned number ranges (000002 s2.1)
#
# A folder owns [own prefix .. next sibling prefix - 1]. With no next sibling it
# inherits its parent's end. A folder Readme that declares an explicit owned
# range wins over the computed one. If start > end the range is nonsense, so the
# folder is not judged at all and is tallied as RANGE_UNDETERMINED.
# ---------------------------------------------------------------------------

$dirRange = @{}
# ArrayList, not a plain array: inside Build-DirRanges a "+=" would rebind a NEW
# local variable and the appends would be silently lost. .Add() mutates in place.
$rangeUndetermined = New-Object System.Collections.ArrayList

function Get-ReadmeDeclaredRange {
    param([string] $DirFull)
    $readmes = @(Get-ChildItem -LiteralPath $DirFull -File -Filter '*_Readme_*.md' -ErrorAction SilentlyContinue)
    foreach ($rm in $readmes) {
        $txt = $null
        try { $txt = [System.IO.File]::ReadAllText($rm.FullName, [System.Text.Encoding]::UTF8) } catch { continue }
        # Owned range: `NNNNNN~NNNNNN`   /   Owned range: NNNNNN-NNNNNN
        if ($txt -match '(?i)Owned\s+range\s*:\s*`?\s*(\d{6})\s*[~\-]\s*(\d{6})') {
            return @([int]$Matches[1], [int]$Matches[2])
        }
        # folder-owned range of NNNNNN~NNNNNN
        if ($txt -match '(?i)folder-owned\s+range\s+of\s+`?\s*(\d{6})\s*[~\-]\s*(\d{6})') {
            return @([int]$Matches[1], [int]$Matches[2])
        }
        # Korean form: <folder> <band>: `NNNNNN`-`NNNNNN`, en/em dash tolerated.
        # Built from code points so this source file stays pure ASCII - PowerShell
        # 5.1 decodes BOM-less scripts as ANSI and would corrupt literal Hangul.
        $koBand = [string]([char]0xD3F4) + [string]([char]0xB354) + '\s*' +
                  [string]([char]0xBC34) + [string]([char]0xB4DC)
        $dashes = '[~\-' + [string]([char]0x2013) + [string]([char]0x2014) + ']'
        $koPattern = '(?i)' + $koBand + '\s*:\s*`?(\d{6})`?\s*' + $dashes + '\s*`?(\d{6})`?'
        if ($txt -match $koPattern) {
            return @([int]$Matches[1], [int]$Matches[2])
        }
    }
    return $null
}

function Build-DirRanges {
    param([string] $DirFull, [int] $ParentEnd)

    $children = @(Get-ChildItem -LiteralPath $DirFull -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -match '^(\d{6})' } |
                  Sort-Object { [int]($_.Name.Substring(0, 6)) })

    for ($i = 0; $i -lt $children.Count; $i++) {
        $childRel = Get-RelPath $children[$i].FullName
        if ($null -ne (Get-ExclusionReason $childRel)) { continue }

        $start = [int]($children[$i].Name.Substring(0, 6))
        if ($i -lt $children.Count - 1) {
            $end = [int]($children[$i + 1].Name.Substring(0, 6)) - 1
        } else {
            $end = $ParentEnd
        }

        $declared = Get-ReadmeDeclaredRange $children[$i].FullName
        if ($null -ne $declared) {
            $start = $declared[0]
            $end   = $declared[1]
        }

        if ($start -gt $end) {
            $null = $rangeUndetermined.Add([pscustomobject]@{
                Dir   = $childRel
                Start = $start
                End   = $end
            })
        }
        else {
            $dirRange[$childRel] = @($start, $end)
        }
        Build-DirRanges $children[$i].FullName $end
    }

    # docs root itself owns [0 .. first child prefix - 1]
    if ($DirFull -eq $Root) {
        $rootEnd = 999999
        if ($children.Count -gt 0) { $rootEnd = [int]($children[0].Name.Substring(0, 6)) - 1 }
        if (0 -le $rootEnd) { $dirRange[''] = @(0, $rootEnd) }
        else {
            $null = $rangeUndetermined.Add([pscustomobject]@{ Dir = 'docs/ (root)'; Start = 0; End = $rootEnd })
        }
    }
}

Build-DirRanges $Root 999999

foreach ($d in $docs) {
    if ($null -eq $d.Num) { continue }
    $dir = $d.Dir
    if ($dir -eq $d.Rel) { $dir = '' }
    if (-not $dirRange.ContainsKey($dir)) { continue }   # non-numeric or undetermined
    $r = $dirRange[$dir]
    if ($d.Num -lt $r[0] -or $d.Num -gt $r[1]) {
        $owner = $dir
        if ($owner.Length -eq 0) { $owner = 'docs/ (root)' }
        Add-Finding 'G05' $d.Rel ("number {0:D6} outside owned range {1:D6}-{2:D6} of {3}" -f $d.Num, $r[0], $r[1], $owner)
    }
}

# ---------------------------------------------------------------------------
# G06 - folders without a numeric prefix
# ---------------------------------------------------------------------------

if ($null -eq $RestrictDocs) {
    foreach ($dir in $allDirs) {
        $rel = Get-RelPath $dir.FullName
        $segments = $rel.Split('/')
        $exempt = $false
        foreach ($ex in $PrefixExemptDirs) {
            if ($segments -contains $ex) { $exempt = $true }
        }
        if ($exempt) { continue }
        if ($dir.Name -notmatch '^\d{6}') {
            Add-Finding 'G06' $rel 'folder name does not start with a six-digit prefix'
        }
    }
}

# ---------------------------------------------------------------------------
# G07 - governed top-level folder must have a correctly numbered Readme
# ---------------------------------------------------------------------------

$topDirs = @(Get-ChildItem -LiteralPath $Root -Directory -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -match '^(\d{6})' } |
             Where-Object { $null -eq (Get-ExclusionReason (Get-RelPath $_.FullName)) })

if ($null -eq $RestrictDocs) {
    foreach ($td in $topDirs) {
        $prefix = [int]($td.Name.Substring(0, 6))
        $rel = Get-RelPath $td.FullName
        $readmes = @($allDocs | Where-Object { $_.Dir -eq $rel -and $_.Type -eq 'Readme' })
        if ($readmes.Count -eq 0) {
            Add-Finding 'G07' $rel 'no Readme document directly in this governed folder'
        }
        else {
            foreach ($rm in $readmes) {
                if ($rm.Num -ne $prefix) {
                    Add-Finding 'G07' $rm.Rel ("Readme number {0:D6} does not match folder prefix {1:D6}" -f $rm.Num, $prefix)
                }
            }
        }
    }
}

# ---------------------------------------------------------------------------
# G08 - duplicate document numbers
# ---------------------------------------------------------------------------

# grouped over ALL in-scope docs so a staged file is still matched against
# files that are not part of this run
$byNum = $allDocs | Where-Object { $null -ne $_.Num } | Group-Object -Property Num
foreach ($g in $byNum) {
    if ($g.Count -lt 2) { continue }
    $paths = @($g.Group | ForEach-Object { $_.Rel } | Sort-Object)
    foreach ($p in $paths) {
        if ($null -ne $RestrictDocs -and -not $RestrictDocs.Contains($p)) { continue }
        $others = @($paths | Where-Object { $_ -ne $p })
        $shown = $others
        $extra = ''
        if ($others.Count -gt 3) {
            $shown = $others[0..2]
            $extra = (' (+{0} more)' -f ($others.Count - 3))
        }
        Add-Finding 'G08' $p ("number {0} also used by: {1}{2}" -f $g.Name, ($shown -join ' ; '), $extra)
    }
}

# ---------------------------------------------------------------------------
# G09 / G10 / G13 - content pass
# ---------------------------------------------------------------------------

$utf8Strict  = New-Object System.Text.UTF8Encoding($false, $true)
$linkRegex   = New-Object System.Text.RegularExpressions.Regex '\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)'

foreach ($d in $docs) {
    $bytes = $null
    try { $bytes = [System.IO.File]::ReadAllBytes($d.Full) } catch { continue }

    # --- G10 encoding ---
    $encIssues = @()
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $encIssues += 'UTF-8 BOM present'
    }
    $text = $null
    try { $text = $utf8Strict.GetString($bytes) }
    catch {
        $encIssues += 'not valid UTF-8'
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    if ($encIssues -notcontains 'not valid UTF-8') {
        $lf   = ([regex]::Matches($text, "`n")).Count
        $crlf = ([regex]::Matches($text, "`r`n")).Count
        $cr   = ([regex]::Matches($text, "`r")).Count
        if ($lf -gt 0 -and $crlf -gt 0 -and $crlf -ne $lf) {
            $encIssues += ("mixed EOL (LF={0} CRLF={1})" -f $lf, $crlf)
        }
        elseif ($cr -ne $crlf) {
            $encIssues += ("stray CR (CR={0} CRLF={1})" -f $cr, $crlf)
        }
    }
    if ($encIssues.Count -gt 0) {
        Add-Finding 'G10' $d.Rel ($encIssues -join ', ')
    }

    if ($null -eq $text) { continue }
    $lines = $text -split "`r?`n"

    # --- G09 H1 (000002 s6: match the filename MEANING, not the literal string)
    $h1 = $null
    foreach ($ln in $lines) {
        if ($ln.Trim().Length -eq 0) { continue }
        if ($ln -match '^#\s+(.*)$') { $h1 = $Matches[1].Trim() }
        break
    }
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($d.Name)

    if ($null -eq $h1) {
        Add-Finding 'G09' $d.Rel 'first non-empty line is not an H1 heading' 'ERROR'
    }
    else {
        $fileNum = $null
        if ($d.Name -match '^(\d{6})') { $fileNum = $Matches[1] }
        $h1Num = $null
        if ($h1 -match '(\d{6})') { $h1Num = $Matches[1] }

        if ($null -ne $fileNum -and $null -ne $h1Num -and $fileNum -ne $h1Num) {
            Add-Finding 'G09' $d.Rel ("H1 number {0} differs from filename number {1} - H1: '{2}'" -f $h1Num, $fileNum, $h1) 'ERROR'
        }
        else {
            $sim = Get-TitleSimilarity $h1 $stem
            if ($sim -lt $H1SimilarityFloor) {
                Add-Finding 'G09' $d.Rel ("normalized similarity {0:P1} (floor {1:P0}) - H1: '{2}'" -f $sim, $H1SimilarityFloor, $h1) 'WARN'
            }
        }
    }

    # --- G13 relative markdown links ---
    foreach ($m in $linkRegex.Matches($text)) {
        $target = $m.Groups[1].Value
        if ($target -match '^(https?:|mailto:|#)') { continue }
        $target = $target.Split('#')[0]
        if ($target.Length -eq 0) { continue }
        if ($target -notmatch '\.md$') { continue }
        $target = $target.Replace('\', '/')

        $resolved = $null
        if ($target.StartsWith('docs/')) {
            $resolved = $target.Substring(5)
        }
        else {
            $baseDir = $d.Dir
            if ($baseDir -eq $d.Rel) { $baseDir = '' }
            $combined = $baseDir
            if ($combined.Length -gt 0) { $combined = $combined + '/' + $target } else { $combined = $target }
            $stack = New-Object System.Collections.ArrayList
            foreach ($part in $combined.Split('/')) {
                if ($part -eq '.' -or $part.Length -eq 0) { continue }
                if ($part -eq '..') {
                    if ($stack.Count -gt 0) { $stack.RemoveAt($stack.Count - 1) }
                    continue
                }
                $null = $stack.Add($part)
            }
            $resolved = ($stack -join '/')
        }
        if ($resolved.Length -eq 0) { continue }
        # resolve against the UNFILTERED set - an excluded target still exists
        if (-not $allFileRelSet.Contains($resolved)) {
            Add-Finding 'G13' $d.Rel ("link target not found: {0}" -f $target)
        }
    }
}

# ---------------------------------------------------------------------------
# G11 - 000005 registry drift
# ---------------------------------------------------------------------------

$indexPath = Join-Path $Root '000005_Index_Document_Number.md'
if (Test-Path -LiteralPath $indexPath) {
    $idxText = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
    $registered = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($m in [regex]::Matches($idxText, 'docs[\\/][^|\s`)]+\.md')) {
        $p = $m.Value.Replace('\', '/')
        if ($p.StartsWith('docs/')) { $p = $p.Substring(5) }
        $null = $registered.Add($p)
    }

    foreach ($d in $docs) {
        if (-not $registered.Contains($d.Rel)) {
            Add-Finding 'G11' $d.Rel 'file exists but is not registered in 000005'
        }
    }
    if ($null -eq $RestrictDocs) {
        foreach ($p in $registered) {
            if ($null -ne (Get-ExclusionReason $p)) { continue }
            # existence tested against the UNFILTERED set
            if (-not $allFileRelSet.Contains($p)) {
                Add-Finding 'G11' $p '000005 registers this path but the file does not exist'
            }
        }
    }
}
else {
    Write-Output 'WARNING: 000005_Index_Document_Number.md not found - G11 skipped.'
}

# ---------------------------------------------------------------------------
# G12 - 000007 directory-map drift
#
# 000007 stores the tree as an indented ASCII drawing, not as full paths, so this
# check is name-level and therefore WARN, not ERROR.
# ---------------------------------------------------------------------------

$mapPath = Join-Path $Root '000007_Map_Full_Directory.md'
if ($null -ne $RestrictDocs) {
    # repository-wide map comparison is not about the given paths
}
elseif (Test-Path -LiteralPath $mapPath) {
    $mapText = [System.IO.File]::ReadAllText($mapPath, [System.Text.Encoding]::UTF8)

    $mappedDirNames = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($m in [regex]::Matches($mapText, '(?m)^[\s+|\\-]*([0-9]{6}_[A-Za-z0-9_]+)/\s*$')) {
        $null = $mappedDirNames.Add($m.Groups[1].Value)
    }

    foreach ($dir in $allDirs) {
        if ($dir.Name -notmatch '^\d{6}') { continue }
        $rel = Get-RelPath $dir.FullName
        if (-not $mappedDirNames.Contains($dir.Name)) {
            Add-Finding 'G12' $rel 'folder exists but is not listed in 000007'
        }
    }
    foreach ($n in $mappedDirNames) {
        # existence tested against the UNFILTERED name set
        if (-not $allDirNameSet.Contains($n)) {
            Add-Finding 'G12' $n '000007 lists this folder but it does not exist'
        }
    }
}
else {
    Write-Output 'WARNING: 000007_Map_Full_Directory.md not found - G12 skipped.'
}

# ---------------------------------------------------------------------------
# G15 - Stage 7 gate: migration applied without human approval
#       (000701 s10, s6.11.1)
#
# Background: on 2026-08-10 it was confirmed that 0168/0169 were applied and the
# packet ran to Stage 12 while 601505 s10 still recorded "Stage 7 (Human
# Approval) | pending". 000701 s10.1 defines Stage 7 as the approval gate
# between design and implementation. This check catches that shape.
#
# The workpacket header itself is required by 000701 s6.11.1 (Migration
# Workpacket Header Rule, 2026-08-11). That rule is not retroactive: the 167
# migrations predating it carry no header, are tallied as NO_HEADER, and are
# never counted as violations, because 000701 s14.5 forbids editing them.
# ---------------------------------------------------------------------------

$g15NoHeader          = 0
$g15ContractNotFound  = 0
$g15Unparseable       = 0
$g15Checked           = 0

function Get-HeadingRefFor {
    param([string[]] $Lines, [int] $Index)
    for ($i = $Index; $i -ge 0; $i--) {
        if ($Lines[$i] -match '^#{1,6}\s+(.*)$') {
            $h = $Matches[1]
            if ($h -match '(\d+)') { return ('s' + $Matches[1]) }
            return $h.Trim()
        }
    }
    return ''
}

function Get-Stage7State {
    param([string[]] $Lines)

    # (a) an "Approval State" style table row for Stage 7
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\|\s*Stage\s*7\b[^|]*\|([^|]*)\|') {
            $cell = ($Matches[1] -replace '\*', '').Trim()
            $ref  = Get-HeadingRefFor $Lines $i
            if ($cell -match '(?i)approved' -or $cell.Contains($KoApproved)) {
                return @{ Kind = 'APPROVED'; State = $cell; Ref = $ref }
            }
            if ($cell -match '(?i)pending' -or $cell.Contains($KoPending) -or $cell.Contains($KoNotStarted)) {
                return @{ Kind = 'PENDING'; State = $cell; Ref = $ref }
            }
        }
    }

    # (b) a Human Approval decision checkbox line
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '(?i)^\s*Decision\s*:') {
            $ln  = $Lines[$i]
            $ref = Get-HeadingRefFor $Lines $i
            if ($ln -match '(?i)\[[xX]\]\s*APPROVE') {
                return @{ Kind = 'APPROVED'; State = 'Decision [x] APPROVE'; Ref = $ref }
            }
            if ($ln -match '\[\s*\]') {
                return @{ Kind = 'PENDING'; State = 'Decision checkboxes all empty'; Ref = $ref }
            }
        }
    }

    # (c) a bare APPROVED (YYYY-MM-DD) stamp
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '(?i)APPROVED\s*\((\d{4}-\d{2}-\d{2})\)') {
            return @{ Kind = 'APPROVED'; State = ('APPROVED (' + $Matches[1] + ')'); Ref = (Get-HeadingRefFor $Lines $i) }
        }
    }

    return @{ Kind = 'UNPARSEABLE'; State = ''; Ref = '' }
}

function Find-ChangeContract {
    param([string] $WpNumber)
    # 1) folders whose name starts with the workpacket number
    $dirs = @(Get-ChildItem -LiteralPath $Root -Recurse -Directory -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -like ($WpNumber + '*') } |
              Where-Object { $null -eq (Get-ExclusionReason (Get-RelPath $_.FullName)) })
    foreach ($dd in $dirs) {
        $hit = @(Get-ChildItem -LiteralPath $dd.FullName -Recurse -File -Filter '*ChangeContract*.md' -ErrorAction SilentlyContinue |
                 Where-Object { $null -eq (Get-ExclusionReason (Get-RelPath $_.FullName)) })
        if ($hit.Count -gt 0) { return $hit[0] }
    }
    # 2) fallback: any ChangeContract whose filename carries the number
    $hit2 = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*ChangeContract*.md' -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -like ('*' + $WpNumber + '*') } |
              Where-Object { $null -eq (Get-ExclusionReason (Get-RelPath $_.FullName)) })
    if ($hit2.Count -gt 0) { return $hit2[0] }
    return $null
}

if (Test-Path -LiteralPath $MigrationsDir -PathType Container) {
    $wpRegex = '(?i)(?:Workpacket|' + $KoWorkpacket + ')\s*:?\s*(\d{6})'
    $migFiles = @(Get-ChildItem -LiteralPath $MigrationsDir -File -Filter '*.sql' -ErrorAction SilentlyContinue | Sort-Object Name)

    foreach ($mf in $migFiles) {
        if ($null -ne $RestrictMigrations -and -not $RestrictMigrations.Contains($mf.Name)) { continue }
        $head = $null
        try { $head = (Get-Content -LiteralPath $mf.FullName -TotalCount 5 -Encoding UTF8) -join "`n" } catch { continue }

        if ($head -notmatch $wpRegex) { $g15NoHeader++; continue }
        $wp = $Matches[1]
        $g15Checked++

        $migRel = 'sql/migrations/' + $mf.Name
        $bandOf = Get-BandLetter ($wp + '_x/y')

        $cc = Find-ChangeContract $wp
        if ($null -eq $cc) {
            $g15ContractNotFound++
            $sev = 'WARN'
            if ($StrictStage7) { $sev = 'ERROR' }
            Add-Finding 'G15' $migRel ("workpacket {0} -> no ChangeContract document found`nCONTRACT_NOT_FOUND" -f $wp) $sev $bandOf ''
            continue
        }

        $ccLines = $null
        try { $ccLines = [System.IO.File]::ReadAllText($cc.FullName, [System.Text.Encoding]::UTF8) -split "`r?`n" }
        catch { $ccLines = @() }

        $state = Get-Stage7State $ccLines
        $ccRel = Get-RelPath $cc.FullName
        $ccNum = 'ChangeContract'
        if ($cc.Name -match '^(\d{6})') { $ccNum = $Matches[1] }

        if ($state.Kind -eq 'APPROVED') { continue }

        if ($state.Kind -eq 'UNPARSEABLE') {
            $g15Unparseable++
            Add-Finding 'G15' $migRel ("workpacket {0} -> {1}`nStage 7 state could not be parsed`nAPPROVAL_UNPARSEABLE" -f $wp, $cc.Name) 'WARN' '' $ccRel
            continue
        }

        # PENDING - the gate was open when the migration landed
        $sev = 'WARN'
        if ($StrictStage7) { $sev = 'ERROR' }
        $detail = ("workpacket {0} -> {1}" -f $wp, $cc.Name) + "`n" +
                  ("Stage 7 state: {0}  ({1} {2})" -f $state.State, $ccNum, $state.Ref) + "`n" +
                  ("contract: {0}" -f $ccRel) + "`n" +
                  'MIGRATION_WITHOUT_APPROVAL'
        Add-Finding 'G15' $migRel $detail $sev '' $ccRel
    }
}
else {
    Write-Output ('WARNING: {0} not found - G15 skipped.' -f $MigrationsDir)
}

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

$sep  = '=' * 92
$sep2 = '-' * 92

Write-Output ''
Write-Output $sep
Write-Output ' GOVERNANCE CONFORMANCE REPORT'
Write-Output $sep
Write-Output ("  docs root : {0}" -f $Root)
if ($Band) { Write-Output ("  band      : {0} (filtered)" -f $Band) }
else       { Write-Output  '  band      : ALL (600000 included - no HOLD exemption)' }
if ($Top -gt 0) { Write-Output ("  top       : {0} shown per check (summary shows full counts)" -f $Top) }
else            { Write-Output  '  top       : 0 = unlimited' }
if ($IncludeExcluded) { Write-Output '  exclusions: DISABLED (-IncludeExcluded)' }
else                  { Write-Output ("  exclusions: ON - {0} files, {1} directories not scanned" -f $excludedFileCount, $excludedDirCount) }
Write-Output ("  files     : {0} markdown documents scanned" -f $docs.Count)
Write-Output ''
Write-Output '  Severity:  ERROR = confirmed rule violation'
Write-Output '             WARN  = needs review, cannot be asserted mechanically'
Write-Output '             REVIEW= list only, this checker makes no judgement'
Write-Output ''

$bandLetters = @('A', 'B', 'C', 'D')
if ($null -ne $FilterLetter) { $bandLetters = @($FilterLetter) }

foreach ($bl in $bandLetters) {
    $inBand = @($Findings | Where-Object { $_.Band -eq $bl })
    Write-Output ''
    Write-Output $sep
    Write-Output (' {0}    {1} finding(s)' -f $BandTitles[$bl], $inBand.Count)
    Write-Output $sep

    if ($inBand.Count -eq 0) {
        Write-Output '  (clean)'
        continue
    }

    foreach ($cid in $CheckCatalog.Keys) {
        $rows = @($inBand | Where-Object { $_.Check -eq $cid } | Sort-Object Path)
        if ($rows.Count -eq 0) { continue }

        $shown = $rows
        $capped = $false
        if ($Top -gt 0 -and $rows.Count -gt $Top) {
            $shown = $rows[0..($Top - 1)]
            $capped = $true
        }

        Write-Output ''
        Write-Output ('{0}  {1}' -f $cid, $CheckCatalog[$cid].Text)
        if ($cid -eq 'G04') {
            Write-Output '  REVIEW LIST ONLY - these are not asserted violations. No date-based'
            Write-Output '  grandfathering is applied; see 000002 s1.2 for the title-component rule.'
        }
        if ($cid -eq 'G15') {
            Write-Output '  Workpacket header required by 000701 s6.11.1 (2026-08-11), not retroactive.'
            Write-Output '  Runs as WARN; -StrictStage7 or GOVERNANCE_STRICT=1 escalates to ERROR.'
        }
        if ($cid -eq 'G09') {
            Write-Output ('  ERROR = missing H1 or H1/filename number mismatch. WARN = normalized' )
            Write-Output ('  similarity below {0:P0}. Separators and case are stripped before comparing.' -f $H1SimilarityFloor)
        }
        if ($capped) {
            Write-Output ('  {0} found, showing first {1} (-Top 0 for all)' -f $rows.Count, $Top)
        }
        else {
            Write-Output ('  {0} found' -f $rows.Count)
        }
        Write-Output $sep2
        foreach ($r in $shown) {
            Write-Output ('  [{0,-6}] {1}' -f $r.Severity, $r.Path)
            foreach ($dl in ($r.Detail -split "`n")) {
                Write-Output ('      {0}' -f $dl)
            }
        }
    }
}

# --- RANGE_UNDETERMINED ----------------------------------------------------

Write-Output ''
Write-Output ''
Write-Output $sep
Write-Output (' RANGE_UNDETERMINED - {0} folder(s) not judged by G05' -f $rangeUndetermined.Count)
Write-Output $sep
if ($rangeUndetermined.Count -eq 0) {
    Write-Output '  (none)'
}
else {
    Write-Output '  Computed start > end, so the owned range is nonsense and no file in these'
    Write-Output '  folders is counted as a G05 violation. Fix the folder numbering or declare'
    Write-Output '  an explicit "Owned range:" in the folder Readme.'
    Write-Output $sep2
    foreach ($ru in ($rangeUndetermined | Sort-Object Dir)) {
        Write-Output ('  {0}' -f $ru.Dir)
        Write-Output ('      computed range {0:D6}-{1:D6} (start > end)' -f $ru.Start, $ru.End)
    }
}

# --- summary --------------------------------------------------------------

Write-Output ''
Write-Output ''
Write-Output $sep
Write-Output ' SUMMARY - full counts, never truncated by -Top'
Write-Output $sep
Write-Output ('{0,-5} {1,-7} {2,-50} {3,5} {4,5} {5,5} {6,5} {7,7}' -f 'ID', 'Sev', 'Check', '[A]', '[B]', '[C]', '[D]', 'TOTAL')
Write-Output $sep2

$colTotals = @{ 'A' = 0; 'B' = 0; 'C' = 0; 'D' = 0 }
$grand = 0

foreach ($cid in $CheckCatalog.Keys) {
    $rows = @($Findings | Where-Object { $_.Check -eq $cid })
    $a = @($rows | Where-Object { $_.Band -eq 'A' }).Count
    $b = @($rows | Where-Object { $_.Band -eq 'B' }).Count
    $c = @($rows | Where-Object { $_.Band -eq 'C' }).Count
    $dd = @($rows | Where-Object { $_.Band -eq 'D' }).Count
    $colTotals['A'] += $a; $colTotals['B'] += $b; $colTotals['C'] += $c; $colTotals['D'] += $dd
    $grand += $rows.Count

    $sev = $CheckCatalog[$cid].Sev
    if ($sev -eq 'MIXED') {
        $nErr = @($rows | Where-Object { $_.Severity -eq 'ERROR' }).Count
        $nWarn = @($rows | Where-Object { $_.Severity -eq 'WARN' }).Count
        $sev = ('E{0}/W{1}' -f $nErr, $nWarn)
    }

    $label = $CheckCatalog[$cid].Text
    if ($label.Length -gt 50) { $label = $label.Substring(0, 50) }
    Write-Output ('{0,-5} {1,-7} {2,-50} {3,5} {4,5} {5,5} {6,5} {7,7}' -f $cid, $sev, $label, $a, $b, $c, $dd, $rows.Count)
}

Write-Output $sep2
Write-Output ('{0,-5} {1,-7} {2,-50} {3,5} {4,5} {5,5} {6,5} {7,7}' -f '', '', 'TOTAL', $colTotals['A'], $colTotals['B'], $colTotals['C'], $colTotals['D'], $grand)
Write-Output $sep

# severity rollup
$nError  = @($Findings | Where-Object { $_.Severity -eq 'ERROR' }).Count
$nWarn   = @($Findings | Where-Object { $_.Severity -eq 'WARN' }).Count
$nReview = @($Findings | Where-Object { $_.Severity -eq 'REVIEW' }).Count

Write-Output ''
Write-Output ' SEVERITY ROLLUP'
Write-Output $sep2
Write-Output ('  ERROR   {0,6}   confirmed rule violations' -f $nError)
Write-Output ('  WARN    {0,6}   needs review, not asserted' -f $nWarn)
Write-Output ('  REVIEW  {0,6}   list only, no judgement' -f $nReview)
Write-Output ('  TOTAL   {0,6}' -f $grand)
Write-Output ''
Write-Output ' SCAN COVERAGE'
Write-Output $sep2
Write-Output ('  scanned            {0,6} markdown files' -f $docs.Count)
if ($IncludeExcluded) {
    Write-Output  '  excluded                0 (-IncludeExcluded was set)'
}
else {
    Write-Output ('  excluded           {0,6} markdown files, {1} directories' -f $excludedFileCount, $excludedDirCount)
    foreach ($k in ($excludedReasonTally.Keys | Sort-Object)) {
        Write-Output ('      {0,5}  {1}' -f $excludedReasonTally[$k], $k)
    }
}
Write-Output ('  RANGE_UNDETERMINED {0,6} folders not judged by G05' -f $rangeUndetermined.Count)
Write-Output ''
Write-Output ' G15 STAGE 7 GATE COVERAGE'
Write-Output $sep2
Write-Output ('  migrations checked   {0,6} carry a workpacket header' -f $g15Checked)
Write-Output ('  NO_HEADER            {0,6} (predates s6.11.1; not a violation - 000701 s14.5)' -f $g15NoHeader)
Write-Output ('  CONTRACT_NOT_FOUND   {0,6} header present but no ChangeContract located' -f $g15ContractNotFound)
Write-Output ('  APPROVAL_UNPARSEABLE {0,6} contract found but Stage 7 state not parseable' -f $g15Unparseable)
if ($StrictStage7) { Write-Output '  mode                 STRICT - G15 counted as ERROR' }
else               { Write-Output '  mode                 default - G15 counted as WARN (-StrictStage7 to escalate)' }
Write-Output $sep
Write-Output ''
Write-Output 'Notes:'
Write-Output '  * Read-only scan. Nothing was written, renamed, staged or committed.'
Write-Output '  * 600000 band is scanned like every other band. Its 2026-08-10 AUTHORITY'
Write-Output '    SUSPENDED ruling concerns design authority, not filename or index format.'
Write-Output '  * G04 lists filenames only and applies no date-based grandfathering.'
Write-Output '  * G09 compares meaning, not the literal string (000002 s6).'
Write-Output '  * G12 is name-level: 000007 stores an indented tree, not full paths.'
Write-Output '  * G14 never fires under 990000_legacy_quarantine: those Group C files were'
Write-Output '    600000-band artifacts relocated by quarantine, not misused DocumentTypes.'
Write-Output '  * Link and existence checks resolve against ALL files on disk, including'
Write-Output '    excluded ones, so exclusions never manufacture missing-target findings.'
Write-Output '  * G15 reads sql/migrations/*.sql headers and the matching ChangeContract.'
Write-Output '    The header is required by 000701 s6.11.1 (2026-08-11), which is not'
Write-Output '    retroactive: migrations predating it are tallied as NO_HEADER, never'
Write-Output '    counted as violations - 000701 s14.5 forbids editing them.'
Write-Output '  * Exit code is always 0. This is a report, not a CI gate.'
Write-Output ''

exit 0
