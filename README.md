# 🐍 Python Version Switcher for Windows ⚙️

A simple yet powerful PowerShell script to quickly switch between multiple Python versions on your Windows machine. It intelligently scans for existing Python installations and updates your user PATH environment variable to prioritize the version you select.

## Overview

For developers working on multiple projects, managing different Python versions can be a challenge. This script automates the process of discovering all Python installations on your system and allows you to select which one should be the default `python` command in your terminal. It directly manipulates the user's PATH variable, ensuring that the selected version's `python.exe` and `Scripts` directory are given top priority.

The solution consists of two files:
*   `python_switcher.ps1`: The core PowerShell script that handles detection and path management.
*   `python_switcher.bat`: A convenient launcher that executes the PowerShell script with the correct policy, making it easy to run.

## ✨ Features

*   **🔎 Automatic Detection**: Scans multiple common locations to find all installed Python versions, including user-specific, system-wide, and Python Launcher (`py.exe`) installations.
*   **🚀 Future-Proof**: Not limited to specific Python versions (e.g., Python 3.9, 3.10). It will find any `python.exe` in the searched directories.
*   **⌨️ Interactive Interface**: Presents a clear, numbered list of found Python installations to choose from.
*   **🛡️ Safe PATH Management**:
    *   Intelligently adds the selected Python version and its `Scripts` folder to the beginning of your user PATH for immediate priority.
    *   Cleans up potential duplicate entries for the selected version before adding it.
*   **⚡ Immediate Effect**: Updates the PATH for the current terminal session, so you can test the change right away. For the change to be system-wide, a new terminal session is required.
*   **▶️ User-Friendly Launcher**: Comes with a `.bat` file to handle the PowerShell execution policy, allowing you to run it with a simple double-click.

## ✅ Requirements

*   **🖥️ Windows Operating System**: This script is designed for Windows environments.
*   **🔵 PowerShell**: Pre-installed on modern Windows versions.
*   **🐍 At least one Python version installed**: The script needs something to find!

## 🚀 How to Use

1.  **Download Files**: Place both `python_switcher.ps1` and `python_switcher.bat` in the same directory.

2.  **Run the script**: Simply double-click the `python_switcher.bat` file.
    *   This will open a PowerShell window.
    *   Alternatively, you can open a command prompt or PowerShell, navigate to the directory, and run `.\python_switcher.bat`.

3.  **Select a Version**:
    *   The script will display the currently active Python version and then list all the versions it discovered.
    *   Enter the number corresponding to the Python version you wish to set as the default.
    *   Enter `0` to exit without making any changes.

    ```
    Current Python version:
    Python 3.9.8

    Scanning for Python installations...

    Found 3 Python installation(s):

    1. Python 3.11.0 - C:\Users\YourUser\AppData\Local\Programs\Python\Python311
       [User Installation]
    2. Python 3.9.8 - C:\Program Files\Python39
       [System Installation]
    3. Python 3.8.10 - C:\Python38
       [System Installation]

    0. Exit without changes

    Select Python version to set as default (0-3):
    ```

4.  **Confirm**: After selecting a version, you will be asked for confirmation. Type `Y` and press Enter to proceed.

5.  **Restart Your Terminal**: For the changes to take full effect system-wide, you must **open a new terminal or command prompt session**. The script will update the PATH for the current session, but other open terminals will not be affected.

## 💡 Notes

*   **Administrator Privileges**: While the script is designed to modify the *user* PATH variable and generally doesn't require administrator rights, running as an administrator can help avoid potential permission issues. If you encounter errors, try right-clicking `python_switcher.bat` and selecting "Run as administrator".
*   **Environment Variables**: This script modifies the `PATH` environment variable for the **current user only**. It does not alter the system-wide `PATH` variable.
*   **Python Launcher (`py.exe`)**: This script sets the default `python` command. The `py.exe` launcher will still be available and can be used to run specific versions (e.g., `py -3.9 my_script.py`).

## ⚠️ Disclaimer

This script modifies your system's environment variables. While it is designed to be safe, please use it at your own risk. It is always a good practice to understand what a script does before running it.
