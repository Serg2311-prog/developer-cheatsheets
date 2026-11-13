#Requires -Version 5.1
<#
.SYNOPSIS
  Шаблон надёжного PowerShell-скрипта: параметры, строгий режим ошибок, try/catch/finally.

.DESCRIPTION
  Создаёт временный каталог, пишет приветствие и гарантированно удаляет каталог в finally.
  Не изменяет файлы вне временного каталога.

.EXAMPLE
  powershell -NoProfile -File examples/powershell/safe_script_template.ps1 -Name Сергей -VerboseMsg a b
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Name = 'мир',

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Remaining = @(),

    [switch] $VerboseMsg
)

$ErrorActionPreference = 'Stop'
$workdir = $null

function Write-ScriptLog {
    param([string] $Message)
    $ts = Get-Date -Format 'HH:mm:ss'
    Write-Host "[$ts] $Message" -ForegroundColor DarkGray
}

try {
    $workdir = Join-Path ([System.IO.Path]::GetTempPath()) ("pcs-safe-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $workdir | Out-Null
    if ($VerboseMsg) {
        Write-ScriptLog "временный каталог: $workdir"
    }

    $greetingFile = Join-Path $workdir 'greeting.txt'
    Set-Content -Path $greetingFile -Value ("Привет, {0}!" -f $Name) -Encoding UTF8
    Get-Content -Path $greetingFile -Encoding UTF8

    Write-Output ("Передано позиционных аргументов: {0}" -f $Remaining.Count)
    foreach ($arg in $Remaining) {
        Write-Output ("  - {0}" -f $arg)
    }

    if ($VerboseMsg) {
        Write-ScriptLog 'готово, временный каталог будет удалён'
    }
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
finally {
    if ($workdir -and (Test-Path -LiteralPath $workdir)) {
        Remove-Item -LiteralPath $workdir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
