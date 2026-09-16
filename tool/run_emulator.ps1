# Pixel_9 에뮬레이터를 검은 화면 없이, 정해진 위치/크기로 실행합니다.
# 사용법: powershell -ExecutionPolicy Bypass -File tool\run_emulator.ps1

$avdName = "Pixel_9"
$emulatorExe = Join-Path $env:LOCALAPPDATA "Android\Sdk\emulator\emulator.exe"

# 원하는 창 위치/크기 (필요하면 이 네 값만 바꾸면 됩니다)
$windowX = 100
$windowY = 100
$windowWidth = 320
$windowHeight = 677

if (-not (Test-Path $emulatorExe)) {
    Write-Host "emulator.exe를 찾을 수 없습니다: $emulatorExe"
    exit 1
}

Start-Process -FilePath $emulatorExe -ArgumentList "-avd", $avdName, "-gpu", "swiftshader_indirect"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class MovieLogEmuWindow {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
}
"@

Write-Host "에뮬레이터 창이 뜨길 기다리는 중..."
$proc = $null
for ($i = 0; $i -lt 60; $i++) {
    $proc = Get-Process -Name "qemu-system-x86_64" -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 }
    if ($proc) { break }
    Start-Sleep -Milliseconds 500
}

if ($proc) {
    Start-Sleep -Seconds 1
    [MovieLogEmuWindow]::MoveWindow($proc.MainWindowHandle, $windowX, $windowY, $windowWidth, $windowHeight, $true)
    Write-Host "창 위치/크기 조정 완료 ($windowX,$windowY / $windowWidth x $windowHeight)"
} else {
    Write-Host "에뮬레이터 창을 찾지 못했습니다. 수동으로 위치를 조정해주세요."
}
