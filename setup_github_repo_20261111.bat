@echo off
chcp 65001 >nul
title GitHub 快速設定懶人包 - 2026-11-11
echo 正在啟動 GitHub 快速設定懶人包...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_github_repo_20261111.ps1"
if %errorlevel% neq 0 (
    echo.
    echo 執行過程中發生錯誤，請查看上方訊息。
    pause
)
