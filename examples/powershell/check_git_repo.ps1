#Requires -Version 5.1
<#
.SYNOPSIS
  Проверка Git-репозитория: корень, статус, ветка, remote, последние коммиты.

.DESCRIPTION
  Только читающие команды git. Не делает commit/push/reset и не меняет файлы.
  Код выхода: 0 — успех, 1 — git недоступен или путь не является репозиторием.

.EXAMPLE
  powershell -NoProfile -File examples/powershell/check_git_repo.ps1 -Path .
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path = '.'
)

$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $GitArgs
    )
    $output = & git @GitArgs 2>&1
    $code = $LASTEXITCODE
    [pscustomobject]@{
        Code   = $code
        Output = @($output | ForEach-Object { "$_" })
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git не найден в PATH'
    exit 1
}

$resolved = Resolve-Path -LiteralPath $Path
Set-Location -LiteralPath $resolved

Write-Output ("== Git-репозиторий: {0}" -f $resolved)

$top = Invoke-Git -GitArgs @('rev-parse', '--show-toplevel')
if ($top.Code -ne 0) {
    Write-Error ("не Git-репозиторий: {0}" -f ($top.Output -join ' '))
    exit 1
}
Write-Output ("Корень:  {0}" -f ($top.Output -join ''))

$branch = Invoke-Git -GitArgs @('branch', '--show-current')
Write-Output ("Ветка:   {0}" -f (($branch.Output -join '').Trim()))

$status = Invoke-Git -GitArgs @('status', '-sb')
Write-Output 'Статус:'
$status.Output | ForEach-Object { Write-Output ("  {0}" -f $_) }

$remote = Invoke-Git -GitArgs @('remote', '-v')
Write-Output 'Remote:'
if ($remote.Output.Count -eq 0) {
    Write-Output '  (нет)'
}
else {
    $remote.Output | Select-Object -Unique | ForEach-Object { Write-Output ("  {0}" -f $_) }
}

$log = Invoke-Git -GitArgs @('log', '-5', '--oneline', '--decorate')
Write-Output 'Последние коммиты:'
if ($log.Code -ne 0) {
    Write-Output '  (история недоступна — возможно, ещё нет коммитов)'
}
else {
    $log.Output | ForEach-Object { Write-Output ("  {0}" -f $_) }
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Output 'GitHub CLI:'
    $gh = & gh auth status 2>&1
    @($gh | ForEach-Object { "$_" }) | Select-Object -First 5 | ForEach-Object {
        Write-Output ("  {0}" -f $_)
    }
}
else {
    Write-Output 'GitHub CLI: gh не установлен (необязательно)'
}

Write-Output ''
Write-Output 'Проверка Git завершена (только чтение).'
exit 0
