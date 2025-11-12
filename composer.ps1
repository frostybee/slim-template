# This is a PowerShell script that calls the composer.bat file in the Wampoon's root directory.
# Use it to run composer for installing and updating dependencies for the project.
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$composerBat = Join-Path $scriptDir '..\..\composer.bat'

if (-not (Test-Path -Path $composerBat)) {
    throw "composer.bat not found at $composerBat"
}

& $composerBat @Args
exit $LASTEXITCODE

