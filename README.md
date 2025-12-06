# 🔧 Environment Version Switcher Toolkit for Windows ⚙️

A comprehensive suite of PowerShell scripts to quickly switch between multiple versions of Python, CUDA, cuDNN, and Visual Studio BuildTools on your Windows machine. Each tool intelligently scans for existing installations and updates your system environment variables to prioritize the version you select.

![Environment Version Switcher](https://img.shields.io/badge/Platform-Windows-blue) ![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-green) ![License](https://img.shields.io/badge/License-MIT-yellow)

## 📋 Overview

Managing multiple development environment versions can be challenging. This toolkit automates the process of discovering installations and switching between them by manipulating environment variables and PATH settings. Perfect for developers working across multiple projects with different toolchain requirements.

## 🎯 What's Included

### 1. 🐍 **Python Version Switcher**
- Scans multiple locations for Python installations
- Updates user PATH variable
- Works with Python Launcher (`py.exe`) installations
- No administrator privileges required

### 2. 🎮 **CUDA Version Switcher**
- Detects all NVIDIA CUDA Toolkit installations
- Updates `CUDA_PATH` system variable
- Manages system PATH for CUDA binaries
- **Requires Administrator privileges**

### 3. 🧠 **cuDNN Version Switcher**
- Scans `C:\Program Files\NVIDIA\CUDNN` for versions
- Updates system PATH for cuDNN binaries
- **Requires Administrator privileges**

### 4. 🏗️ **Visual Studio BuildTools Switcher**
- Finds all MSVC compiler installations (cl.exe)
- Supports VS 2019, 2022, and newer versions
- Updates `cl.exe` system variable and PATH
- **Requires Administrator privileges**

### 5. 🚀 **Master Launcher (start.bat)**
- Unified menu interface for all switchers
- Quick access to any tool
- Streamlined workflow

## ✅ Requirements

- **🖥️ Windows Operating System**: Windows 10/11 recommended
- **🔵 PowerShell**: Pre-installed on modern Windows
- **🔐 Administrator Rights**: Required for CUDA, cuDNN, and VS BuildTools switchers
- **📦 At least one version installed**: For each tool you want to use

## 🚀 Quick Start

### Master Launcher (Recommended)

1. **Download all files** to the same directory
2. **Double-click `start.bat`**
3. **Select the tool** you want to use from the menu:

```
========================================
     Environment Version Switcher
========================================

   1. Python Version Switcher
   2. CUDA Version Switcher             (Requires Admin)
   3. cuDNN Version Switcher            (Requires Admin)
   4. VS (BuildTools) Version Switcher  (Requires Admin)

   0. Exit

========================================
Select an option [0-4]:
```

### Individual Usage

You can also run each switcher independently by double-clicking its `.bat` file:
- `python_switcher.bat`
- `cuda_switcher.bat`
- `cudnn_switcher.bat`
- `vs_buildtools_switcher.bat`

## 📖 Detailed Usage

### 🐍 Python Version Switcher

**Features:**
- Scans `%LOCALAPPDATA%\Programs\Python`, `%ProgramFiles%`, and system directories
- Detects Python Launcher installations
- Updates user PATH (no admin needed)
- Removes duplicate entries before adding selected version

**Example Output:**
```
Found 3 Python installation(s):

1. Python 3.12.0 - C:\Users\YourUser\AppData\Local\Programs\Python\Python312
   [User Installation]
2. Python 3.11.5 - C:\Users\YourUser\AppData\Local\Programs\Python\Python311
   [User Installation]
3. Python 3.9.13 - C:\Program Files\Python39
   [System Installation]

0. Exit without changes
```

### 🎮 CUDA Version Switcher

**Features:**
- Detects versions via `CUDA_PATH_V*_*` environment variables
- Updates `CUDA_PATH` system variable
- Cleans old CUDA paths from system PATH
- Adds `bin`, `libnvvp`, `bin\x64`, and `extras\CUPTI\lib64` folders
- Verifies installation with `nvcc --version`

**Example Output:**
```
Found 2 CUDA installation(s):

1. CUDA v13.1 - C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.1
2. CUDA v11.8 - C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8

0. Exit without changes
```

**Admin Required:** ✅ This tool modifies system environment variables.

### 🧠 cuDNN Version Switcher

**Features:**
- Scans `C:\Program Files\NVIDIA\CUDNN`
- Removes old cuDNN paths from system PATH
- Adds selected version's `bin` folder to PATH

**Example Output:**
```
Found 2 cuDNN installation(s):

1. cuDNN v9.0.0.312_cuda12 - C:\Program Files\NVIDIA\CUDNN\v9.0.0.312_cuda12\bin
2. cuDNN v8.9.7.29_cuda11 - C:\Program Files\NVIDIA\CUDNN\v8.9.7.29_cuda11\bin

0. Exit without changes
```

**Admin Required:** ✅ This tool modifies system environment variables.

### 🏗️ Visual Studio BuildTools Switcher

**Features:**
- Scans both `Program Files` and `Program Files (x86)`
- Finds all VS editions (BuildTools, Community, Professional, Enterprise)
- Supports VS 2019, 2022, and future versions
- Sets `cl.exe` system variable
- Uses `Hostx64\x64` for native 64-bit compilation

**Example Output:**
```
Found 2 installation(s):

1. v14.44.35207 - 2022 BuildTools
   Path: C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64
2. v14.39.33519 - 2022 Community
   Path: C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.39.33519\bin\Hostx64\x64

0. Exit without changes
```

**Admin Required:** ✅ This tool modifies system environment variables.

## 🔒 Administrator Privileges

### Tools That Need Admin:
- ✅ **CUDA Switcher** - Modifies system variables
- ✅ **cuDNN Switcher** - Modifies system variables
- ✅ **VS BuildTools Switcher** - Modifies system variables

### Tools That Don't Need Admin:
- ❌ **Python Switcher** - Only modifies user PATH

When admin is required, the `.bat` launcher will automatically request elevation via UAC prompt.

## 💡 Important Notes

### Environment Variable Scopes
- **Python Switcher**: Modifies `PATH` for current user only
- **CUDA/cuDNN/VS Switchers**: Modify system-wide variables (all users)

### Taking Effect
After switching versions:
1. **Close and reopen** all Command Prompts, PowerShell windows, and IDEs
2. **For CUDA/VS tools**: If changes don't take effect, **reboot Windows**
3. **Current session**: The script updates the current terminal for immediate testing

### Safety Features
- ✅ Confirmation prompt before making changes
- ✅ Shows exactly what will be modified
- ✅ Removes old/duplicate paths to prevent conflicts
- ✅ Only adds folders that actually exist on disk
- ✅ Graceful error handling with clear messages

## 🛠️ Troubleshooting

### "No installations found"
- Ensure the software is installed in standard locations
- For CUDA: Check if `CUDA_PATH_V*_*` environment variables exist
- For cuDNN: Check `C:\Program Files\NVIDIA\CUDNN`
- For VS: Check `C:\Program Files\Microsoft Visual Studio`

### Changes don't take effect
1. Restart your terminal/IDE completely
2. Open a **new** Command Prompt or PowerShell window
3. For system variables (CUDA/VS), try rebooting Windows

### "Requires Administrator privileges" error
- Right-click the `.bat` file
- Select **"Run as administrator"**
- Or use the master launcher which handles elevation automatically

### PowerShell execution policy errors
- The `.bat` launchers use `-ExecutionPolicy Bypass` flag
- This bypasses policy for just that session (safe)
- No permanent system changes needed

## 📁 File Structure

```
Environment-Switcher/
├── start.bat                      # Master launcher menu
├── python_switcher.bat            # Python launcher
├── python_switcher.ps1            # Python core script
├── cuda_switcher.bat              # CUDA launcher
├── cuda_switcher.ps1              # CUDA core script
├── cudnn_switcher.bat             # cuDNN launcher
├── cudnn_switcher.ps1             # cuDNN core script
├── vs_buildtools_switcher.bat     # VS BuildTools launcher
├── vs_buildtools_switcher.ps1     # VS BuildTools core script
└── README.md                      # This file
```

## 🎨 Features Highlight

### Intelligent Path Management
- Automatically removes duplicate entries
- Validates folder existence before adding to PATH
- Prioritizes selected version at the top of PATH
- Preserves other environment variables

### Future-Proof Design
- Not hardcoded to specific versions
- Works with Python 3.x, CUDA 11.x/12.x/13.x+, any VS version
- Automatically adapts to new installations
- Version detection via folder scanning and registry checks

### User Experience
- Color-coded console output for clarity
- Clear version numbers and paths displayed
- Numbered selection menus (no typing long paths)
- Confirmation prompts to prevent accidents
- Immediate verification of changes

## ⚠️ Disclaimer

These scripts modify your system's environment variables. While designed to be safe and include multiple confirmation steps, please use at your own risk. Always understand what a script does before running it with administrator privileges.

**Best Practice:** Test on a non-critical machine first if you're uncertain.

## 📝 Version History

- **v2.0** - Complete toolkit with master launcher
- **v1.2** - Added VS BuildTools switcher
- **v1.1** - Added CUDA and cuDNN switchers
- **v1.0** - Initial Python version switcher

## 🤝 Contributing

Found a bug or have a feature request? Feel free to open an issue or submit a pull request!

## 📄 License

MIT License - Feel free to use, modify, and distribute as needed.

---

**Made with ❤️ for developers who need to juggle multiple environment versions**