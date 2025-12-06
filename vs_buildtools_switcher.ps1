# Microsoft Visual Studio (BuildTools) Switcher - PowerShell Script
# Switches System Environment Variables for Visual C++ Compiler (cl.exe)
# Scans C:\Program Files (and x86) for Visual Studio versions

param()

# Set console properties
$Host.UI.RawUI.WindowTitle = "Microsoft Visual Studio (BuildTools) Switcher"
Clear-Host

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "   Microsoft Visual Studio (BuildTools) Switcher v1.2" -ForegroundColor Green  
Write-Host "==========================================================" -ForegroundColor Green
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
    # 1. Define Search Roots
    # We check both standard Program Files folders
    $searchRoots = @(
        "$env:ProgramFiles\Microsoft Visual Studio",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio"
    )
    
    Write-Host "Scanning for Visual Studio installations..." -ForegroundColor Yellow
    $vsInstallations = @()

    foreach ($root in $searchRoots) {
        if (Test-Path $root) {
            # Get Years (2019, 2022, etc.)
            $years = Get-ChildItem $root -Directory -ErrorAction SilentlyContinue
            foreach ($yearDir in $years) {
                
                # Get Editions (BuildTools, Community, Professional, Enterprise)
                $editions = Get-ChildItem $yearDir.FullName -Directory -ErrorAction SilentlyContinue
                foreach ($editionDir in $editions) {
                    
                    # Look for MSVC folder
                    $msvcRoot = Join-Path $editionDir.FullName "VC\Tools\MSVC"
                    
                    if (Test-Path $msvcRoot) {
                        # Get Exact Version Numbers (e.g., 14.44.35207)
                        $versions = Get-ChildItem $msvcRoot -Directory -ErrorAction SilentlyContinue
                        foreach ($verDir in $versions) {
                            
                            # Construct the Hostx64/x64 path
                            # Note: We specifically look for Hostx64\x64 for native 64-bit compilation
                            $binPath = Join-Path $verDir.FullName "bin\Hostx64\x64"
                            $clExe = Join-Path $binPath "cl.exe"

                            if (Test-Path $clExe) {
                                # Generate a friendly name
                                $friendlyName = "$($yearDir.Name) $($editionDir.Name)"
                                
                                # Create Object
                                $obj = [PSCustomObject]@{
                                    Name       = $friendlyName
                                    Version    = $verDir.Name
                                    Path       = $binPath
                                    FullClPath = $clExe
                                }
                                
                                $vsInstallations += $obj
                            }
                        }
                    }
                }
            }
        }
    }

    # Sort Descending by Version Number
    $vsInstallations = $vsInstallations | Sort-Object Version -Descending

    if ($vsInstallations.Count -eq 0) {
        Write-Host "No Visual Studio (cl.exe) installations found!" -ForegroundColor Red
        Write-Host "Checked locations inside: Microsoft Visual Studio folders" -ForegroundColor Yellow
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    Write-Host "Found $($vsInstallations.Count) installation(s):" -ForegroundColor Green
    Write-Host ""
    
    for ($i = 0; $i -lt $vsInstallations.Count; $i++) {
        $inst = $vsInstallations[$i]
        $number = $i + 1
        
        Write-Host "$number. " -NoNewline -ForegroundColor White
        Write-Host "v$($inst.Version)" -NoNewline -ForegroundColor Cyan
        Write-Host " - $($inst.Name)" -ForegroundColor Gray
        
        # Display FULL Path (No truncation)
        Write-Host "   Path: $($inst.Path)" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    Write-Host "0. " -NoNewline -ForegroundColor White
    Write-Host "Exit without changes" -ForegroundColor Red
    Write-Host ""

    # 3. User Selection
    do {
        $choice = Read-Host "Select Compiler version to set as default (0-$($vsInstallations.Count))"
        if ($choice -eq "0") { exit 0 }
        $choiceNum = $choice -as [int]
        if ($choiceNum -ge 1 -and $choiceNum -le $vsInstallations.Count) { break }
        Write-Host "Invalid choice!" -ForegroundColor Red
    } while ($true)

    $selected = $vsInstallations[$choiceNum - 1]
    
    Write-Host ""
    Write-Host "Selected: " -NoNewline -ForegroundColor White
    Write-Host "$($selected.Name) - v$($selected.Version)" -NoNewline -ForegroundColor Cyan
    Write-Host ""

    # 4. Confirmation
    do {
        $confirm = Read-Host "Update System Variables? (Y/N)"
        if ($confirm -match "^[Yy]") { break }
        if ($confirm -match "^[Nn]") { exit 0 }
    } while ($true)

    Write-Host ""
    Write-Host "Updating System Environment Variables..." -ForegroundColor Yellow

    # --- ACTION 1: Set Variable 'cl.exe' ---
    Write-Host "1. Setting System Variable 'cl.exe'..." -ForegroundColor White
    [Environment]::SetEnvironmentVariable("cl.exe", $selected.Path, "Machine")
    Write-Host "   Set 'cl.exe' to: $($selected.Path)" -ForegroundColor DarkGray

    # --- ACTION 2: Update System PATH ---
    Write-Host "2. Updating System Path..." -ForegroundColor White
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (-not $currentPath) { $currentPath = "" }
    
    $pathArray = $currentPath -split ";" | Where-Object { $_.Trim() -ne "" }
    
    # FILTER OLD VISUAL STUDIO PATHS
    # We remove old paths that look like MSVC compiler paths
    $filteredPathArray = @()
    $removedCount = 0

    foreach ($p in $pathArray) {
        # Pattern match for standard MSVC paths
        if ($p -match "VC\\Tools\\MSVC" -and $p -match "bin\\Host") {
            $removedCount++
        } else {
            $filteredPathArray += $p
        }
    }

    if ($removedCount -gt 0) {
        Write-Host "   Removed $removedCount old compiler path entries." -ForegroundColor DarkYellow
    }

    # COMBINE AND SAVE
    # Add selected path to the top
    $finalPathArray = @($selected.Path) + $filteredPathArray
    $finalPathString = $finalPathArray -join ";"

    [Environment]::SetEnvironmentVariable("Path", $finalPathString, "Machine")
    
    Write-Host "   Added to top: $($selected.Path)" -ForegroundColor Green

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Success! System Variables Updated." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT:" -ForegroundColor Yellow
    Write-Host "1. Restart any open Command Prompts, PowerShells, or IDEs." -ForegroundColor Yellow
    Write-Host "2. To verify, open a new terminal and type: cl" -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "FATAL ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")