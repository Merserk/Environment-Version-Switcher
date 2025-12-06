# cuDNN Version Switcher - PowerShell Script
# Switches System Environment Variables for NVIDIA cuDNN
# Scans C:\Program Files\NVIDIA\CUDNN

param()

# Set console properties
$Host.UI.RawUI.WindowTitle = "cuDNN Version Switcher"
Clear-Host

Write-Host "========================================" -ForegroundColor Green
Write-Host "      cuDNN Version Switcher v1.0" -ForegroundColor Green  
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check Admin Privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "Error: This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run the .bat file as Administrator." -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

try {
    # 1. Define Search Path
    $basePath = "$env:ProgramFiles\NVIDIA\CUDNN"
    
    Write-Host "Scanning location: $basePath" -ForegroundColor DarkGray
    Write-Host ""

    if (-not (Test-Path $basePath)) {
        Write-Host "Folder not found: $basePath" -ForegroundColor Red
        Write-Host "Please ensure cuDNN is installed in the standard location." -ForegroundColor Yellow
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    # 2. Scan for Versions
    $cudnnInstallations = @()
    $dirs = Get-ChildItem $basePath -Directory

    foreach ($dir in $dirs) {
        # Check if 'bin' exists inside (required for PATH)
        $binPath = Join-Path $dir.FullName "bin"
        
        if (Test-Path $binPath) {
            $cudnnInstallations += @{
                Version = $dir.Name
                Path = $dir.FullName
                BinPath = $binPath
            }
        }
    }

    # Sort Descending (Newest first)
    $cudnnInstallations = $cudnnInstallations | Sort-Object Name -Descending

    if ($cudnnInstallations.Count -eq 0) {
        Write-Host "No valid cuDNN installations found!" -ForegroundColor Red
        Write-Host "Looking for subfolders containing a 'bin' directory." -ForegroundColor Yellow
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    Write-Host "Found $($cudnnInstallations.Count) cuDNN installation(s):" -ForegroundColor Green
    Write-Host ""
    
    for ($i = 0; $i -lt $cudnnInstallations.Count; $i++) {
        $inst = $cudnnInstallations[$i]
        $number = $i + 1
        Write-Host "$number. " -NoNewline -ForegroundColor White
        Write-Host "cuDNN $($inst.Version)" -NoNewline -ForegroundColor Cyan
        Write-Host " - $($inst.BinPath)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "0. " -NoNewline -ForegroundColor White
    Write-Host "Exit without changes" -ForegroundColor Red
    Write-Host ""

    # 3. User Selection
    do {
        $choice = Read-Host "Select cuDNN version to set as default (0-$($cudnnInstallations.Count))"
        if ($choice -eq "0") { exit 0 }
        $choiceNum = $choice -as [int]
        if ($choiceNum -ge 1 -and $choiceNum -le $cudnnInstallations.Count) { break }
        Write-Host "Invalid choice!" -ForegroundColor Red
    } while ($true)

    $selected = $cudnnInstallations[$choiceNum - 1]
    
    Write-Host ""
    Write-Host "Selected: " -NoNewline -ForegroundColor White
    Write-Host "cuDNN $($selected.Version)" -NoNewline -ForegroundColor Cyan
    Write-Host ""

    # 4. Confirmation
    do {
        $confirm = Read-Host "Update System PATH Variable? (Y/N)"
        if ($confirm -match "^[Yy]") { break }
        if ($confirm -match "^[Nn]") { exit 0 }
    } while ($true)

    Write-Host ""
    Write-Host "Updating System Environment Variables..." -ForegroundColor Yellow

    # --- Update System PATH ---
    
    # Get current System PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (-not $currentPath) { $currentPath = "" }
    
    $pathArray = $currentPath -split ";" | Where-Object { $_.Trim() -ne "" }
    
    # FILTER OLD CUDNN PATHS
    # We look for paths containing "NVIDIA\CUDNN" to remove old versions
    $filteredPathArray = @()
    $removedCount = 0

    foreach ($p in $pathArray) {
        if ($p -match "NVIDIA\\CUDNN") {
            $removedCount++
        } else {
            $filteredPathArray += $p
        }
    }

    if ($removedCount -gt 0) {
        Write-Host "   Removed $removedCount old cuDNN path entries." -ForegroundColor DarkYellow
    }

    # COMBINE AND SAVE
    # Add new bin path to the top
    $finalPathArray = @($selected.BinPath) + $filteredPathArray
    $finalPathString = $finalPathArray -join ";"

    [Environment]::SetEnvironmentVariable("Path", $finalPathString, "Machine")
    
    Write-Host "   Added to top: $($selected.BinPath)" -ForegroundColor Green

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Success! System PATH Updated." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT:" -ForegroundColor Yellow
    Write-Host "1. Restart any open Command Prompts, PowerShells, or IDEs." -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "FATAL ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")