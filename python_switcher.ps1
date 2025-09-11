# Python Version Switcher - PowerShell Script
# Works with any Python version and is future-proof

param()

# Set console properties for better visibility
$Host.UI.RawUI.WindowTitle = "Python Version Switcher"
Clear-Host

Write-Host "========================================" -ForegroundColor Green
Write-Host "     Python Version Switcher v2.0" -ForegroundColor Green  
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Function to get Python version from executable
function Get-PythonVersion {
    param([string]$PythonPath)
    try {
        $version = & "$PythonPath" --version 2>&1
        if ($version -match "Python\s+(\d+\.\d+\.\d+)") {
            return $matches[1]
        }
        return "Unknown"
    }
    catch {
        return "Unknown"
    }
}

# Function to check if path is already in PATH environment variable
function Test-PathInEnvironment {
    param([string]$TestPath)
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    return $currentPath -split ";" -contains $TestPath
}

try {
    # Show current Python version
    Write-Host "Current Python version:" -ForegroundColor Cyan
    try {
        $currentVersion = python --version 2>&1
        Write-Host $currentVersion -ForegroundColor White
    }
    catch {
        Write-Host "No Python found in current PATH" -ForegroundColor Yellow
    }
    Write-Host ""

    # Array to store Python installations
    $pythonInstallations = @()

    Write-Host "Scanning for Python installations..." -ForegroundColor Yellow
    Write-Host ""

    # Define search locations (future-proof - will find any Python version)
    $searchLocations = @(
        "$env:LOCALAPPDATA\Programs\Python",
        "$env:APPDATA\Python", 
        "$env:ProgramFiles\Python*",
        "$env:ProgramFiles\Microsoft\WindowsApps",
        "${env:ProgramFiles(x86)}\Python*",
        "$env:SystemDrive\Python*"
    )

    # Search in user AppData (most common for newer Python installations)
    if (Test-Path "$env:LOCALAPPDATA\Programs\Python") {
        $userPythonDirs = Get-ChildItem "$env:LOCALAPPDATA\Programs\Python" -Directory -ErrorAction SilentlyContinue
        foreach ($dir in $userPythonDirs) {
            $pythonExe = Join-Path $dir.FullName "python.exe"
            if (Test-Path $pythonExe) {
                $version = Get-PythonVersion $pythonExe
                $pythonInstallations += @{
                    Path = $dir.FullName
                    Version = $version
                    Executable = $pythonExe
                    Type = "User Installation"
                }
            }
        }
    }

    # Search in system-wide locations  
    foreach ($location in $searchLocations) {
        if ($location -like "*\*") {
            # Handle wildcard paths
            $basePath = Split-Path $location -Parent
            $pattern = Split-Path $location -Leaf
            
            if (Test-Path $basePath) {
                $dirs = Get-ChildItem $basePath -Directory -Filter $pattern -ErrorAction SilentlyContinue
                foreach ($dir in $dirs) {
                    $pythonExe = Join-Path $dir.FullName "python.exe"
                    if (Test-Path $pythonExe) {
                        # Avoid duplicates
                        $exists = $pythonInstallations | Where-Object { $_.Path -eq $dir.FullName }
                        if (-not $exists) {
                            $version = Get-PythonVersion $pythonExe
                            $pythonInstallations += @{
                                Path = $dir.FullName
                                Version = $version
                                Executable = $pythonExe
                                Type = "System Installation"
                            }
                        }
                    }
                }
            }
        }
        else {
            if (Test-Path $location) {
                $pythonExe = Join-Path $location "python.exe"
                if (Test-Path $pythonExe) {
                    $exists = $pythonInstallations | Where-Object { $_.Path -eq $location }
                    if (-not $exists) {
                        $version = Get-PythonVersion $pythonExe
                        $pythonInstallations += @{
                            Path = $location
                            Version = $version
                            Executable = $pythonExe
                            Type = "System Installation"
                        }
                    }
                }
            }
        }
    }

    # Also check for Python Launcher installations
    $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
    if ($pyLauncher) {
        try {
            $pyVersions = py -0 2>&1 | Where-Object { $_ -match "^\s*-(\d+\.\d+)" }
            foreach ($pyVer in $pyVersions) {
                if ($pyVer -match "^\s*-(\d+\.\d+)") {
                    $versionNumber = $matches[1]
                    try {
                        $pythonPath = & py -$versionNumber -c "import sys; print(sys.executable)" 2>&1
                        if ($pythonPath -and (Test-Path $pythonPath)) {
                            $pythonDir = Split-Path $pythonPath -Parent
                            $exists = $pythonInstallations | Where-Object { $_.Path -eq $pythonDir }
                            if (-not $exists) {
                                $version = Get-PythonVersion $pythonPath
                                $pythonInstallations += @{
                                    Path = $pythonDir
                                    Version = $version
                                    Executable = $pythonPath
                                    Type = "Launcher Detection"
                                }
                            }
                        }
                    }
                    catch { }
                }
            }
        }
        catch { }
    }

    # Sort installations by version (newest first)
    $pythonInstallations = $pythonInstallations | Sort-Object { 
        if ($_.Version -match "(\d+)\.(\d+)\.(\d+)") {
            [version]"$($matches[1]).$($matches[2]).$($matches[3])"
        } else { [version]"0.0.0" }
    } -Descending

    if ($pythonInstallations.Count -eq 0) {
        Write-Host "No Python installations found!" -ForegroundColor Red
        Write-Host "Please install Python first from https://python.org" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    Write-Host "Found $($pythonInstallations.Count) Python installation(s):" -ForegroundColor Green
    Write-Host ""
    
    for ($i = 0; $i -lt $pythonInstallations.Count; $i++) {
        $installation = $pythonInstallations[$i]
        $number = $i + 1
        Write-Host "$number. " -NoNewline -ForegroundColor White
        Write-Host "Python $($installation.Version)" -NoNewline -ForegroundColor Cyan
        Write-Host " - $($installation.Path)" -ForegroundColor Gray
        Write-Host "   [$($installation.Type)]" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    Write-Host "0. " -NoNewline -ForegroundColor White
    Write-Host "Exit without changes" -ForegroundColor Red
    Write-Host ""

    do {
        $choice = Read-Host "Select Python version to set as default (0-$($pythonInstallations.Count))"
        
        if ($choice -eq "0") {
            Write-Host "No changes made." -ForegroundColor Yellow
            Write-Host "Press any key to exit..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
        
        $choiceNum = $choice -as [int]
        if ($choiceNum -ge 1 -and $choiceNum -le $pythonInstallations.Count) {
            break
        }
        
        Write-Host "Invalid choice! Please enter a number between 0 and $($pythonInstallations.Count)." -ForegroundColor Red
    } while ($true)

    $selectedInstallation = $pythonInstallations[$choiceNum - 1]
    
    Write-Host ""
    Write-Host "Selected: " -NoNewline -ForegroundColor White
    Write-Host "Python $($selectedInstallation.Version)" -NoNewline -ForegroundColor Cyan
    Write-Host " - $($selectedInstallation.Path)" -ForegroundColor Gray
    Write-Host ""

    do {
        $confirm = Read-Host "Set this as default Python? (Y/N)"
        if ($confirm -match "^[Yy]([Ee][Ss])?$") {
            break
        }
        if ($confirm -match "^[Nn][Oo]?$") {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            Write-Host "Press any key to exit..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
        Write-Host "Please enter Y or N." -ForegroundColor Red
    } while ($true)

    Write-Host ""
    Write-Host "Updating PATH environment variable..." -ForegroundColor Yellow

    # Get current user PATH
    $currentUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if (-not $currentUserPath) { $currentUserPath = "" }

    # Split PATH into array and remove empty entries
    $pathArray = $currentUserPath -split ";" | Where-Object { $_ -ne "" -and $_.Trim() -ne "" }

    # Only remove the SELECTED Python paths to prevent duplicates
    $selectedPythonPath = $selectedInstallation.Path.Trim()
    $selectedScriptsPath = "$selectedPythonPath\Scripts"
    
    Write-Host "Removing selected Python paths (if they exist) to prevent duplicates..." -ForegroundColor Yellow
    
    # Count removed paths for feedback
    $removedCount = 0
    $originalCount = $pathArray.Count

    # Remove ONLY the selected Python paths
    $pathArray = $pathArray | Where-Object { 
        $path = $_.Trim()
        $isSelectedPythonPath = ($path -eq $selectedPythonPath -or $path -eq $selectedScriptsPath)
        
        if ($isSelectedPythonPath) {
            $removedCount++
            Write-Host "  Removed: $path" -ForegroundColor DarkYellow
        }
        
        return -not $isSelectedPythonPath
    }

    if ($removedCount -gt 0) {
        Write-Host "Removed $removedCount duplicate path(s)" -ForegroundColor Green
    } else {
        Write-Host "No existing paths found for selected Python version" -ForegroundColor Gray
    }

    # Add selected Python paths to the BEGINNING (highest priority)
    Write-Host "Adding selected Python paths to the beginning of PATH..." -ForegroundColor Yellow
    $newPathArray = @($selectedPythonPath, $selectedScriptsPath) + $pathArray
    
    Write-Host "  Added to top: $selectedPythonPath" -ForegroundColor Green
    Write-Host "  Added to top: $selectedScriptsPath" -ForegroundColor Green

    # Join back to string and clean up any double semicolons
    $newPath = ($newPathArray -join ";") -replace ";;+", ";"
    $newPath = $newPath.Trim(";")

    # Update user PATH environment variable
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "PATH updated successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Selected Python version: " -NoNewline -ForegroundColor White
    Write-Host $selectedInstallation.Version -ForegroundColor Cyan
    Write-Host "Python path: " -NoNewline -ForegroundColor White  
    Write-Host $selectedInstallation.Path -ForegroundColor Gray
    Write-Host ""
    Write-Host "NOTE: You may need to:" -ForegroundColor Yellow
    Write-Host "1. Restart your command prompt/terminal" -ForegroundColor Yellow
    Write-Host "2. Or start a new PowerShell session" -ForegroundColor Yellow
    Write-Host "3. Changes take effect immediately in new sessions" -ForegroundColor Yellow
    Write-Host ""

    # Update PATH for current session
    $env:PATH = "$($selectedInstallation.Path);$($selectedInstallation.Path)\Scripts;$env:PATH"

    Write-Host "Testing new Python version:" -ForegroundColor Cyan
    try {
        $testVersion = & "$($selectedInstallation.Executable)" --version 2>&1
        Write-Host $testVersion -ForegroundColor Green
    }
    catch {
        Write-Host "Could not test Python version, but PATH was updated." -ForegroundColor Yellow
    }
    Write-Host ""

}
catch {
    Write-Host ""
    Write-Host "An error occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run this script as Administrator if the error persists." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")