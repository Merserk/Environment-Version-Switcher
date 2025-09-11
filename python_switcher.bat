@echo off
:: Python Version Switcher Launcher
:: This batch file runs the PowerShell script with proper execution policy

title Python Version Switcher

:: Check if PowerShell script exists
if not exist "python_switcher.ps1" (
    echo Error: python_switcher.ps1 not found!
    echo Please make sure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

:: Run PowerShell script with bypass execution policy for this session only
echo Starting Python Version Switcher...
echo.

powershell.exe -ExecutionPolicy Bypass -File "python_switcher.ps1"

:: Check if PowerShell encountered any errors
if errorlevel 1 (
    echo.
    echo An error occurred while running the PowerShell script.
    echo You may need to run this as Administrator.
    echo.
    pause
)

exit /b 0