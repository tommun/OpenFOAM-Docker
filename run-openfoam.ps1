# ==============================================================================
# OpenFOAM ThinkPad Bridge & Launcher
# ==============================================================================
# 役割:
# 1. OpenFOAMコンテナの稼働を確認（停止していれば自動起動）
# 2. work フォルダを監視し、.foam ファイル作成時に Windows側 ParaView 6.1.0 を自動起動
# 3. コンテナ内 bash セッションへシームレスに接続
# ==============================================================================

$WorkDir = "$PSScriptRoot\work"

if (-not (Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}

# ParaView 実行ファイルのパス検出
$ParaViewCandidates = @(
    "C:\Program Files\ParaView 6.1.0\bin\paraview.exe",
    "C:\Program Files\ParaView 6.0.0\bin\paraview.exe",
    "C:\Program Files\ParaView 5.12.0\bin\paraview.exe"
)

$ParaViewPath = $null
foreach ($path in $ParaViewCandidates) {
    if (Test-Path $path) {
        $ParaViewPath = $path
        break
    }
}

if (-not $ParaViewPath) {
    $found = Get-ChildItem "C:\Program Files\ParaView*" -Recurse -Filter paraview.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
    if ($found -and (Test-Path $found)) {
        $ParaViewPath = $found
    }
}

if ($ParaViewPath) {
    Write-Host "[Info] Found ParaView at: $ParaViewPath" -ForegroundColor Cyan
} else {
    Write-Host "[Warning] ParaView was not found on Windows host. (Can still use Web GUI at http://localhost:6080)" -ForegroundColor Yellow
}

# コンテナの稼働確認と起動
$containerStatus = docker inspect -f '{{.State.Running}}' openfoam13-container 2>$null
if ($containerStatus -ne "true") {
    Write-Host "[Info] Starting openfoam13-container..." -ForegroundColor Yellow
    docker start openfoam13-container | Out-Null
    Start-Sleep -Seconds 2
}

# FileSystemWatcher 設定（ParaView 自動起動ブリッジ）
$watcher = $null
$handler = $null

if ($ParaViewPath) {
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $WorkDir
    $watcher.Filter = "*.foam"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true

    $action = {
        $path = $Event.SourceEventArgs.FullPath
        $name = $Event.SourceEventArgs.Name
        Write-Host "`n[Watcher] Detected '$name'. Launching native ParaView (32GB RAM)..." -ForegroundColor Green
        Start-Process $ParaViewPath -ArgumentList "`"$path`""
    }

    $handler = Register-ObjectEvent $watcher "Created" -Action $action
    Write-Host "[Bridge] ParaView watcher active. Run 'touch <case>.foam' inside container to view." -ForegroundColor Green
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Entering OpenFOAM 13 Container..." -ForegroundColor Green
Write-Host " Type 'exit' to leave container and return to Windows." -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan

# コンテナへ対話接続
docker exec -it -u foam openfoam13-container bash

# 終了時のクリーンアップ処理
if ($handler) {
    Write-Host "`n[Bridge] Stopping ParaView watcher..." -ForegroundColor Yellow
    Unregister-Event -SourceIdentifier $handler.Name -ErrorAction SilentlyContinue
}
if ($watcher) {
    $watcher.Dispose()
}

Write-Host "[Bridge] Session closed." -ForegroundColor Gray
