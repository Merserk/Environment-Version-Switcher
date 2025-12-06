@echo off
:: CUDA Version Switcher Launcher
:: Fixes directory issues when elevating to Admin

:: CRITICAL FIX: Switch to the directory where this script is located immediately
cd /d "%~dp0"

title CUDA Version Switcher

:: Check if PowerShell script exists
if not exist "cuda_switcher.ps1" (
    echo Error: cuda_switcher.ps1 not found!
    echo Looking in: %cd%
    echo.
    echo Please make sure both files are in the same directory.
    echo.
    pause
    exit /b 1
)

:: Check for Administrator privileges
echo Checking for Administrator privileges...
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run
) else (
    echo Requesting Administrator privileges...
    goto :getAdmin
)

:getAdmin
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b

:run
    :: Ensure we are still in the correct directory after the jump
    cd /d "%~dp0"
    
    echo Starting CUDA Version Switcher...
    echo.
    powershell.exe -ExecutionPolicy Bypass -File "cuda_switcher.ps1"

exit /b 0