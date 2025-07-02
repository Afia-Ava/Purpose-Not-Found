@echo off
echo ========================================
echo    🎮 PURPOSE NOT FOUND 🎮
echo    Starting Game...
echo ========================================
echo.

REM Check if project.godot exists
if not exist "project.godot" (
    echo ERROR: project.godot not found!
    echo Make sure you're running this from the game folder.
    pause
    exit /b 1
)

echo Looking for Godot...

REM Try common Godot locations
set GODOT_FOUND=0

if exist "C:\Program Files\Godot_v4.4.0-stable_mono_win64\Godot_v4.4.0-stable_mono_win64.exe" (
    echo Found Godot 4.4.0 Mono
    "C:\Program Files\Godot_v4.4.0-stable_mono_win64\Godot_v4.4.0-stable_mono_win64.exe" "%~dp0project.godot"
    set GODOT_FOUND=1
    goto :end
)

if exist "C:\Program Files\Godot\Godot.exe" (
    echo Found Godot in Program Files
    "C:\Program Files\Godot\Godot.exe" "%~dp0project.godot"
    set GODOT_FOUND=1
    goto :end
)

if exist "C:\Program Files (x86)\Godot\Godot.exe" (
    echo Found Godot in Program Files (x86)
    "C:\Program Files (x86)\Godot\Godot.exe" "%~dp0project.godot"
    set GODOT_FOUND=1
    goto :end
)

REM Try PATH
echo Trying godot from PATH...
godot --version >nul 2>&1
if not errorlevel 1 (
    echo Found Godot in PATH
    godot "%~dp0project.godot"
    set GODOT_FOUND=1
    goto :end
)

REM Manual instructions
if %GODOT_FOUND%==0 (
    echo.
    echo ❌ Godot not found automatically!
    echo.
    echo 📋 MANUAL STEPS:
    echo 1. Open Godot Engine
    echo 2. Click "Import"
    echo 3. Navigate to: %~dp0
    echo 4. Select: project.godot
    echo 5. Click "Import & Edit"
    echo 6. Click the Play button (▶️)
    echo.
    echo 💡 You can also double-click "project.godot" file
    echo.
    pause
)

:end
