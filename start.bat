@echo off
:: Master Version Switcher Launcher
:: Allows selection between Python, CUDA, cuDNN, and VS BuildTools switchers

:: Ensure we are in the script's directory
cd /d "%~dp0"
title Environment Version Switcher

:menu
cls
echo ========================================
echo      Environment Version Switcher
echo ========================================
echo.
echo    1. Python Version Switcher
echo    2. CUDA Version Switcher             (Requires Admin)
echo    3. cuDNN Version Switcher            (Requires Admin)
echo    4. VS (BuildTools) Version Switcher  (Requires Admin)
echo.
echo    0. Exit
echo.
echo ========================================
set /p choice="Select an option [0-4]: "

if "%choice%"=="1" goto python
if "%choice%"=="2" goto cuda
if "%choice%"=="3" goto cudnn
if "%choice%"=="4" goto vs_tools
if "%choice%"=="0" exit

:: Invalid choice
echo.
echo Invalid option selected. Please try again.
timeout /t 2 >nul
goto menu

:python
cls
if not exist "python_switcher.bat" (
    echo Error: python_switcher.bat not found!
    pause
    goto menu
)
call "python_switcher.bat"
goto menu

:cuda
cls
if not exist "cuda_switcher.bat" (
    echo Error: cuda_switcher.bat not found!
    pause
    goto menu
)
call "cuda_switcher.bat"
goto menu

:cudnn
cls
if not exist "cudnn_switcher.bat" (
    echo Error: cudnn_switcher.bat not found!
    pause
    goto menu
)
call "cudnn_switcher.bat"
goto menu

:vs_tools
cls
if not exist "vs_buildtools_switcher.bat" (
    echo Error: vs_buildtools_switcher.bat not found!
    pause
    goto menu
)
call "vs_buildtools_switcher.bat"
goto menu