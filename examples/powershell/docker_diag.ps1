#Requires -Version 5.1
<#
.SYNOPSIS
  Диагностика Docker Desktop / Engine и compose-файла примеров.

.DESCRIPTION
  Только чтение: version, info (кратко), ps, compose config.
  Не выполняет down/rm/prune и не удаляет контейнеры, образы или тома.

.EXAMPLE
  powershell -NoProfile -File examples/powershell/docker_diag.ps1
#>
[CmdletBinding()]
param(
    [string] $ComposeFile = ''
)

$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    $here = $PSScriptRoot
    return (Resolve-Path (Join-Path $here '..\..')).Path
}

function Invoke-External {
    param(
        [string] $File,
        [string[]] $ArgumentList
    )
    $out = & $File @ArgumentList 2>&1
    [pscustomobject]@{
        Code   = $LASTEXITCODE
        Output = @($out | ForEach-Object { "$_" })
    }
}

$repo = Get-RepoRoot
if (-not $ComposeFile) {
    $ComposeFile = Join-Path $repo 'examples\docker\compose.yaml'
}

Write-Output '== Docker-диагностика (только чтение)'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error 'docker не найден в PATH'
    exit 1
}

$ver = Invoke-External docker @('version', '--format', '{{.Client.Version}}')
Write-Output ("Клиент: {0}" -f ($ver.Output -join ''))

$server = Invoke-External docker @('info', '--format', '{{.ServerVersion}}')
if ($server.Code -ne 0 -or -not ($server.Output -join '')) {
    Write-Output 'Сервер: недоступен (запустите Docker Desktop и дождитесь статуса Idle)'
    Write-Output 'Продолжаем проверку compose config — она не требует daemon.'
}
else {
    Write-Output ("Сервер: {0}" -f ($server.Output -join ''))
    $ps = Invoke-External docker @('ps', '--format', 'table {{.Names}}\t{{.Status}}\t{{.Ports}}')
    Write-Output 'Контейнеры:'
    $ps.Output | ForEach-Object { Write-Output ("  {0}" -f $_) }
}

$composeOk = $false
$composeVer = Invoke-External docker @('compose', 'version')
if ($composeVer.Code -eq 0) {
    Write-Output ("Compose: {0}" -f ($composeVer.Output -join ' '))
    $composeOk = $true
}
else {
    Write-Output 'docker compose недоступен'
}

if ($composeOk -and (Test-Path -LiteralPath $ComposeFile)) {
    Write-Output ("Проверка: {0}" -f $ComposeFile)
    $cfg = Invoke-External docker @('compose', '-f', $ComposeFile, 'config', '--quiet')
    if ($cfg.Code -eq 0) {
        Write-Output 'compose config: OK'
    }
    else {
        Write-Error ("compose config: FAIL`n{0}" -f ($cfg.Output -join "`n"))
        exit 1
    }
}
elseif (-not (Test-Path -LiteralPath $ComposeFile)) {
    Write-Output ("Файл compose не найден: {0}" -f $ComposeFile)
}

Write-Output ''
Write-Output 'Диагностика Docker завершена. Контейнеры и тома не изменялись.'
exit 0
