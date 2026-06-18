# OpenFOAM ParaView Bridge
# This script watches the 'work' directory and opens ParaView on Windows when a .foam file is created.

$WorkDir = "$PSScriptRoot\work"

if (-not (Test-Path $WorkDir)) {
    Write-Error "Work directory not found at $WorkDir"
    exit
}

$ParaViewPath = "C:\Program Files\ParaView 6.1.0\bin\paraview.exe"

if (-not (Test-Path $ParaViewPath)) {
    Write-Host "Default ParaView path not found. Searching..." -ForegroundColor Gray
    $ParaViewPath = Get-ChildItem "C:\Program Files\ParaView*" -Recurse -Filter paraview.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
}

if (-not $ParaViewPath -or -not (Test-Path $ParaViewPath)) {
    Write-Error "ParaView was not found on your system. Please install it or specify the path in this script."
    exit
}
Write-Host "Using ParaView: $ParaViewPath" -ForegroundColor Gray

# Define the watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $WorkDir
$watcher.Filter = "*.foam"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$action = {
    $path = $Event.SourceEventArgs.FullPath
    $name = $Event.SourceEventArgs.Name
    Write-Host "`n[Watcher] Detected $name. Opening in ParaView..." -ForegroundColor Cyan
    Start-Process $ParaViewPath -ArgumentList "`"$path`""
}

# Register the event
$handler = Register-ObjectEvent $watcher "Created" -Action $action

Write-Host "--- OpenFOAM ParaView Bridge Started ---" -ForegroundColor Green
Write-Host "1. Now entering the container..."
Write-Host "2. Inside the container, run 'paraFoam' to open ParaView on Windows."
Write-Host "3. Type 'exit' to stop the watcher and leave." -ForegroundColor Gray

# Start/Enter the container
# docker-compose up -d # Ensure it's running
docker exec -it openfoam13-container bash

# Cleanup
Write-Host "`nStopping watcher..." -ForegroundColor Yellow
Unregister-Event -SourceIdentifier $handler.Name
$watcher.Dispose()
Write-Host "Bridge closed."
