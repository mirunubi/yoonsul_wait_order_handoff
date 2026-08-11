<#
.SYNOPSIS
    Single source of truth for the docs/ scan exclusion rules.

.DESCRIPTION
    Dot-sourced by tools/Check-Governance.ps1 and tools/Invoke-PreCommitCheck.ps1
    so the exclusion list is defined exactly once. Do not copy these patterns
    anywhere else - add them here and both callers pick them up.

    Paths passed to Test-GovExcluded are docs-relative with forward slashes,
    e.g. "990000_legacy_quarantine/604000_workpackets/x.md", NOT "docs/...".

    This file is pure ASCII on purpose: Windows PowerShell 5.1 decodes BOM-less
    script files as ANSI and would corrupt any non-ASCII literal.
#>

$GovExcludeDirRules = @(
    @{ Pattern = '^990000_legacy_quarantine(/|$)';      Why = 'legacy quarantine - slated for disposal, must not be cited (2026-08-10 decision)' },
    @{ Pattern = '^_migration_history(/|$)';            Why = 'migration history folder' },
    @{ Pattern = '(^|/)archive_duplicate_review(/|$)';  Why = '000001 s5.13 archive/duplicate review area' },
    @{ Pattern = '(^|/)[^/]*_duplicate_review(/|$)';    Why = '000001 s5.13 archive/duplicate review area' },
    @{ Pattern = '^implementation_evidence(/|$)';       Why = '000001 s5.4.2 temporary per-change workspace' }
)

$GovExcludeFileRule = @{ Pattern = '_KO\.md$'; Why = 'Human-reading translation copy' }

# Returns the exclusion reason string, or $null when the path is in scope.
# This function is unconditional: callers that support an "include everything"
# switch must short-circuit before calling it.
function Test-GovExcluded {
    param([string] $RelPath)
    foreach ($rule in $GovExcludeDirRules) {
        if ($RelPath -match $rule.Pattern) { return $rule.Why }
    }
    if ($RelPath -match $GovExcludeFileRule.Pattern) { return $GovExcludeFileRule.Why }
    return $null
}
