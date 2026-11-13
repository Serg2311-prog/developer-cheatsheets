#Requires -Version 5.1
<#
.SYNOPSIS
  Проверки PowerShell-примеров: парсер, PSScriptAnalyzer, запуск демо-скриптов.

.DESCRIPTION
  Не удаляет чужие файлы и контейнеры. Docker-диагностика только читает состояние.
  -Strict: отсутствие PSScriptAnalyzer или провал любой проверки — код выхода 1.
  Без -Strict отсутствие анализатора помечается как SKIP (как ShellCheck в check_all.sh).

.EXAMPLE
  powershell -NoProfile -File examples/powershell/Invoke-Checks.ps1 -Strict
#>
[CmdletBinding()]
param(
    [switch] $Strict,
    [switch] $AllowInstall
)

$ErrorActionPreference = 'Stop'
$failed = 0
$passed = 0
$skipped = 0
$here = $PSScriptRoot
# Явная копия для вложенных функций и PSScriptAnalyzer (PSReviewUnusedParameter)
$script:IsStrict = [bool] $Strict

function Write-Ok {
    param([string] $Message)
    Write-Host ("  [OK]   {0}" -f $Message)
    $script:passed++
}

function Write-Fail {
    param([string] $Message, [string] $Details = '')
    Write-Host ("  [FAIL] {0}" -f $Message)
    if ($Details) {
        $Details -split "`n" | ForEach-Object { Write-Host ("         {0}" -f $_) }
    }
    $script:failed++
}

function Write-Skip {
    param(
        [string] $Message,
        [switch] $Required
    )
    Write-Host ("  [SKIP] {0}" -f $Message)
    $script:skipped++
    # Как ShellCheck в check_all.sh: часть проверок необязательна даже в CI.
    # -Required используют только для PSScriptAnalyzer при -Strict.
    if ($script:IsStrict -and $Required) {
        Write-Fail ("обязательная проверка пропущена (Strict): {0}" -f $Message)
    }
}

function Test-ScriptSyntax {
    param([string] $Path)
    $tokens = $null
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
    return $errors
}

Write-Host '== PowerShell: синтаксис'
$scripts = @(
    Get-ChildItem -LiteralPath $here -Filter '*.ps1' -File |
        Sort-Object Name
)
foreach ($script in $scripts) {
    $errs = Test-ScriptSyntax -Path $script.FullName
    if ($errs -and $errs.Count -gt 0) {
        $msg = ($errs | ForEach-Object { $_.ToString() }) -join "`n"
        Write-Fail ("синтаксис {0}" -f $script.Name) $msg
    }
    else {
        Write-Ok ("синтаксис {0}" -f $script.Name)
    }
}

Write-Host ''
Write-Host '== PowerShell: PSScriptAnalyzer'
$analyzer = Get-Module -ListAvailable -Name PSScriptAnalyzer | Select-Object -First 1
if (-not $analyzer -and $AllowInstall) {
    try {
        Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop |
            Out-Null
        $analyzer = Get-Module -ListAvailable -Name PSScriptAnalyzer | Select-Object -First 1
    }
    catch {
        Write-Skip -Required ("PSScriptAnalyzer не установлен: {0}" -f $_.Exception.Message)
    }
}
elseif (-not $analyzer) {
    Write-Skip -Required 'PSScriptAnalyzer не установлен (Install-Module PSScriptAnalyzer или -AllowInstall)'
}

if ($analyzer) {
    Import-Module PSScriptAnalyzer -ErrorAction Stop
    $settings = Join-Path $here 'PSScriptAnalyzerSettings.psd1'
    $analyzerParams = @{
        Path     = $here
        Recurse  = $true
        Severity = @('Error', 'Warning')
    }
    if (Test-Path -LiteralPath $settings) {
        $analyzerParams['Settings'] = $settings
    }
    $issues = Invoke-ScriptAnalyzer @analyzerParams -ErrorAction Stop |
        Where-Object { $_.ScriptName -like '*.ps1' }
    if ($issues) {
        $details = ($issues | ForEach-Object {
                "{0}:{1} {2} ({3})" -f $_.ScriptName, $_.Line, $_.Message, $_.RuleName
            }) -join "`n"
        Write-Fail 'PSScriptAnalyzer' $details
    }
    else {
        Write-Ok 'PSScriptAnalyzer (Error/Warning)'
    }
}

Write-Host ''
Write-Host '== PowerShell: запуск примеров'
$hostExe = (Get-Process -Id $PID).Path

function Invoke-Example {
    param(
        [string] $Title,
        [string] $File,
        [string[]] $ArgumentList = @()
    )
    $path = Join-Path $here $File
    $allArgs = @('-NoProfile', '-NonInteractive', '-File', $path) + $ArgumentList
    $output = & $hostExe @allArgs 2>&1
    $code = $LASTEXITCODE
    if ($code -eq 0) {
        Write-Ok $Title
    }
    else {
        $text = ($output | ForEach-Object { "$_" }) -join "`n"
        Write-Fail $Title $text
    }
}

Invoke-Example -Title 'safe_script_template.ps1' -File 'safe_script_template.ps1' -ArgumentList @('-Name', 'Тест', '-VerboseMsg', 'a', 'b')

$repoRoot = (Resolve-Path (Join-Path $here '..\..')).Path
Invoke-Example -Title 'check_git_repo.ps1' -File 'check_git_repo.ps1' -ArgumentList @('-Path', $repoRoot)

$onWindows = $env:OS -eq 'Windows_NT'
if ($onWindows) {
    Invoke-Example -Title 'system_info.ps1' -File 'system_info.ps1'
}
else {
    Write-Skip 'system_info.ps1 (нужна Windows)'
}

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Invoke-Example -Title 'docker_diag.ps1' -File 'docker_diag.ps1'
}
else {
    Write-Skip 'docker_diag.ps1 (docker не установлен)'
}

Write-Host ''
Write-Host ("Итого: успешно {0}, с ошибками {1}, пропусков {2}" -f $passed, $failed, $skipped)
if ($failed -gt 0) {
    exit 1
}
exit 0
