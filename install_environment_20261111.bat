@echo off
chcp 65001 >nul
title 全套環境一鍵建置懶人包 - 2026-11-11
echo ==================================================================
echo   正在以系統管理員等級權限啟動環境安裝程序...
echo ==================================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_environment_20261111.ps1"
if %errorlevel% neq 0 (
    echo.
    echo 執行過程中發生警告或錯誤，請查閱上方終端訊息。
    pause
)
