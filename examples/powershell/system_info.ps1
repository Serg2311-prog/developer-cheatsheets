#Requires -Version 5.1
<#
.SYNOPSIS
  Диагностика системы: ОС, CPU, память, диски, слушающие порты, топ процессов.

.DESCRIPTION
  Только чтение. Не останавливает процессы и службы, ничего не удаляет.
  Windows-специфичные разделы пропускаются вне Windows с понятным сообщением.

.EXAMPLE
  powershell -NoProfile -File examples/powershell/system_info.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Test-IsWindowsOS {
    if ($env:OS -eq 'Windows_NT') { return $true }
    try {
        return [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
            [System.Runtime.InteropServices.OSPlatform]::Windows)
    }
    catch {
        return $false
    }
}

function Write-Section {
    param([string] $Title)
    Write-Output ''
    Write-Output ("== {0}" -f $Title)
}

Write-Section 'Оболочка'
Write-Output ("PSVersion: {0}" -f $PSVersionTable.PSVersion)
Write-Output ("PSEdition: {0}" -f $PSVersionTable.PSEdition)
Write-Output ("OS env:    {0}" -f $env:OS)

if (-not (Test-IsWindowsOS)) {
    Write-Section 'Windows'
    Write-Output 'Пропуск: скрипт запущен не на Windows.'
    exit 0
}

Write-Section 'Компьютер'
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $totalMb = [math]::Round($os.TotalVisibleMemorySize / 1024, 1)
    $freeMb = [math]::Round($os.FreePhysicalMemory / 1024, 1)
    Write-Output ("ОС:        {0}" -f $os.Caption)
    Write-Output ("Версия:    {0}" -f $os.Version)
    Write-Output ("Память:    свободно {0} МБ из {1} МБ" -f $freeMb, $totalMb)
}
catch {
    Write-Output ("Не удалось получить Win32_OperatingSystem: {0}" -f $_.Exception.Message)
}

Write-Section 'CPU'
try {
    Get-CimInstance -ClassName Win32_Processor |
        Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, LoadPercentage |
        Format-List | Out-String | Write-Output
}
catch {
    Write-Output ("Не удалось получить Win32_Processor: {0}" -f $_.Exception.Message)
}

Write-Section 'Диски'
Get-PSDrive -PSProvider FileSystem |
    Where-Object { $null -ne $_.Used } |
    Select-Object Name,
        @{ N = 'UsedGB'; E = { [math]::Round($_.Used / 1GB, 2) } },
        @{ N = 'FreeGB'; E = { [math]::Round($_.Free / 1GB, 2) } } |
    Format-Table -AutoSize | Out-String | Write-Output

Write-Section 'Топ процессов по WorkingSet'
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 8 Name, Id,
        @{ N = 'MB'; E = { [math]::Round($_.WorkingSet64 / 1MB, 1) } } |
    Format-Table -AutoSize | Out-String | Write-Output

Write-Section 'Слушающие TCP-порты (первые 15)'
try {
    Get-NetTCPConnection -State Listen -ErrorAction Stop |
        Select-Object -First 15 LocalAddress, LocalPort, OwningProcess |
        Sort-Object LocalPort |
        Format-Table -AutoSize | Out-String | Write-Output
}
catch {
    Write-Output ("Get-NetTCPConnection недоступен: {0}" -f $_.Exception.Message)
}

Write-Section 'Переменные окружения (фрагмент)'
Write-Output ("USERPROFILE={0}" -f $env:USERPROFILE)
Write-Output ("Path (первых 3):")
($env:Path -split ';') | Where-Object { $_ } | Select-Object -First 3 | ForEach-Object {
    Write-Output ("  {0}" -f $_)
}

Write-Output ''
Write-Output 'Диагностика завершена (только чтение).'
exit 0
