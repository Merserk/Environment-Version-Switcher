# CUDA Version Switcher - PowerShell Script
# Switches System Environment Variables for NVIDIA CUDA
# Updated: Checks for folder existence (bin, libnvvp, bin\x64) before adding

param()

# Set console properties
$Host.UI.RawUI.WindowTitle = "CUDA Version Switcher"
Clear-Host

Write-Host "========================================" -ForegroundColor Green
Write-Host "      CUDA Version Switcher v1.1" -ForegroundColor Green  
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
    # 1. Detect Current CUDA_PATH
    Write-Host "Current Configuration:" -ForegroundColor Cyan
    $currentCudaPath = [Environment]::GetEnvironmentVariable("CUDA_PATH", "Machine")
    
    if ($currentCudaPath) {
        Write-Host "CUDA_PATH: " -NoNewline -ForegroundColor White
        Write-Host $currentCudaPath -ForegroundColor Yellow
    } else {
        Write-Host "CUDA_PATH: Not Set" -ForegroundColor Red
    }
    Write-Host ""

    # 2. Scan for Installed Versions
    Write-Host "Scanning for CUDA installations..." -ForegroundColor Yellow
    $cudaInstallations = @()

    $allVars = Get-ChildItem Env:
    foreach ($var in $allVars) {
        if ($var.Name -match "^CUDA_PATH_V(\d+)_(\d+)$") {
            $verMajor = $matches[1]
            $verMinor = $matches[2]
            $friendlyVersion = "$verMajor.$verMinor"
            
            $cudaInstallations += @{
                Version = $friendlyVersion
                Path = $var.Value
                EnvVar = $var.Name
            }
        }
    }

    $cudaInstallations = $cudaInstallations | Sort-Object { [version]$_.Version } -Descending

    if ($cudaInstallations.Count -eq 0) {
        Write-Host "No CUDA installations detected via Environment Variables!" -ForegroundColor Red
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    Write-Host "Found $($cudaInstallations.Count) CUDA installation(s):" -ForegroundColor Green
    Write-Host ""
    
    for ($i = 0; $i -lt $cudaInstallations.Count; $i++) {
        $inst = $cudaInstallations[$i]
        $number = $i + 1
        Write-Host "$number. " -NoNewline -ForegroundColor White
        Write-Host "CUDA v$($inst.Version)" -NoNewline -ForegroundColor Cyan
        Write-Host " - $($inst.Path)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "0. " -NoNewline -ForegroundColor White
    Write-Host "Exit without changes" -ForegroundColor Red
    Write-Host ""

    # 3. User Selection
    do {
        $choice = Read-Host "Select CUDA version to set as default (0-$($cudaInstallations.Count))"
        if ($choice -eq "0") { exit 0 }
        $choiceNum = $choice -as [int]
        if ($choiceNum -ge 1 -and $choiceNum -le $cudaInstallations.Count) { break }
        Write-Host "Invalid choice!" -ForegroundColor Red
    } while ($true)

    $selected = $cudaInstallations[$choiceNum - 1]
    
    Write-Host ""
    Write-Host "Selected: " -NoNewline -ForegroundColor White
    Write-Host "CUDA v$($selected.Version)" -NoNewline -ForegroundColor Cyan
    Write-Host ""

    # 4. Confirmation
    do {
        $confirm = Read-Host "Update System Environment Variables? (Y/N)"
        if ($confirm -match "^[Yy]") { break }
        if ($confirm -match "^[Nn]") { exit 0 }
    } while ($true)

    Write-Host ""
    Write-Host "Updating System Environment Variables..." -ForegroundColor Yellow

    # --- STEP A: Update CUDA_PATH ---
    Write-Host "1. Updating CUDA_PATH..." -ForegroundColor White
    [Environment]::SetEnvironmentVariable("CUDA_PATH", $selected.Path, "Machine")
    Write-Host "   Set to: $($selected.Path)" -ForegroundColor DarkGray

    # --- STEP B: Update System PATH (Dynamic) ---
    Write-Host "2. Updating System Path..." -ForegroundColor White
    
    # Get current System PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (-not $currentPath) { $currentPath = "" }
    
    $pathArray = $currentPath -split ";" | Where-Object { $_.Trim() -ne "" }
    
    # 1. IDENTIFY NEW FOLDERS TO ADD
    # We check a list of common CUDA subfolders. We only add them if they actually exist on disk.
    $possibleSubFolders = @("bin", "libnvvp", "bin\x64", "extras\CUPTI\lib64")
    $newPathsToAdd = @()

    foreach ($sub in $possibleSubFolders) {
        $fullPath = Join-Path $selected.Path $sub
        if (Test-Path $fullPath) {
            $newPathsToAdd += $fullPath
        }
    }

    # 2. FILTER OLD CUDA PATHS
    # Remove any existing path that contains "NVIDIA GPU Computing Toolkit\CUDA"
    # This cleans up old v11.8 paths, old v13.1 paths, etc.
    $filteredPathArray = @()
    $removedCount = 0

    foreach ($p in $pathArray) {
        if ($p -match "NVIDIA GPU Computing Toolkit\\CUDA") {
            $removedCount++
        } else {
            $filteredPathArray += $p
        }
    }

    if ($removedCount -gt 0) {
        Write-Host "   Removed $removedCount old CUDA path entries." -ForegroundColor DarkYellow
    }

    # 3. COMBINE AND SAVE
    # Add new valid paths to the top
    $finalPathArray = $newPathsToAdd + $filteredPathArray
    $finalPathString = $finalPathArray -join ";"

    [Environment]::SetEnvironmentVariable("Path", $finalPathString, "Machine")
    
    # Feedback on what was actually added
    foreach ($added in $newPathsToAdd) {
        Write-Host "   Added: $added" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Success! System Variables Updated." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Selected CUDA: " -NoNewline -ForegroundColor White
    Write-Host "v$($selected.Version)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "IMPORTANT:" -ForegroundColor Yellow
    Write-Host "1. Restart any open Command Prompts, PowerShells, or IDEs." -ForegroundColor Yellow
    Write-Host "2. If 'nvcc' doesn't work, reboot Windows." -ForegroundColor Yellow
    Write-Host ""
    
    # Verify for current session
    $env:CUDA_PATH = $selected.Path
    Write-Host "Current Session Verification (nvcc --version):" -ForegroundColor Cyan
    try {
        # Try to run nvcc from the found bin path
        $binPath = $newPathsToAdd | Where-Object { $_ -match "\\bin$" } | Select-Object -First 1
        if ($binPath) {
            & "$binPath\nvcc.exe" --version | Select-Object -First 4
        } else {
            # If standard bin path wasn't found (rare), try generic
            nvcc --version
        }
    } catch {
        Write-Host "Could not run nvcc immediately (normal until restart)." -ForegroundColor Gray
    }

} catch {
    Write-Host ""
    Write-Host "FATAL ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")