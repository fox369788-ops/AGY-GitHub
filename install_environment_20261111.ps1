# ==============================================================================
# 全套 AI 知識工程與多媒體自動化環境一鍵安裝懶人包
# 建立日期：2026-11-11
# 適用環境：Windows 10 / Windows 11 (64-bit)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "環境建置懶人包 - 2026-11-11"

function Write-Header {
    param([string]$Title)
    Write-Host "`n==================================================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor Cyan
}

function Write-Success { param([string]$Msg) Write-Host "  [✓] $Msg" -ForegroundColor Green }
function Write-Info    { param([string]$Msg) Write-Host "  [i] $Msg" -ForegroundColor Gray }
function Write-Warn    { param([string]$Msg) Write-Host "  [!] $Msg" -ForegroundColor Yellow }
function Write-Err     { param([string]$Msg) Write-Host "  [X] $Msg" -ForegroundColor Red }

# 刷新當前 Process 的 PATH 環境變數
function Refresh-EnvPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path    = "$machinePath;$userPath"
    
    # 常用安裝目錄補充
    $extraPaths = @(
        "C:\Program Files\Git\cmd",
        "C:\Program Files\GitHub CLI",
        "C:\Python314",
        "C:\Python314\Scripts",
        "C:\Program Files\nodejs",
        "C:\Program Files\Tesseract-OCR",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links",
        "$env:USERPROFILE\.cargo\bin"
    )
    foreach ($p in $extraPaths) {
        if ((Test-Path $p) -and ($env:Path -notlike "*$p*")) {
            $env:Path = "$p;$env:Path"
        }
    }
}

Clear-Host
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   全套 AI、多媒體與開發工具一鍵安裝懶人包 (2026-11-11)   " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "即將自動安裝與設定以下工具：" -ForegroundColor White
Write-Host "  1. 系統開發工具：Git, GitHub CLI, Python 3.14, uv, Node.js" -ForegroundColor Gray
Write-Host "  2. 影音多媒體工具：FFmpeg, Gyan FFprobe" -ForegroundColor Gray
Write-Host "  3. 文件 OCR 與知識庫：Tesseract-OCR, Poppler, Obsidian" -ForegroundColor Gray
Write-Host "  4. Python AI 套件：Faster-Whisper, PyTorch, Edge-TTS, MoviePy, Playwright, yt-dlp" -ForegroundColor Gray
Write-Host "  5. 客製自動化技能：auto-video-editor 教學影片自動剪輯工作流" -ForegroundColor Gray
Write-Host "------------------------------------------------------------------" -ForegroundColor Cyan

$confirm = Read-Host "是否開始執行自動安裝？(Y/n)"
if ($confirm -eq 'n' -or $confirm -eq 'N') {
    Write-Warn "安裝已取消。"
    Exit 0
}

# ------------------------------------------------------------------------------
# 第一階段：檢查與安裝 Windows 套件管理器 (winget) 工具
# ------------------------------------------------------------------------------
Write-Header "第一階段：透過 winget 安裝系統軟體與 CLI 工具"

$wingetPackages = @(
    @{ Name = "Git";                  Id = "Git.Git";                  CheckCmd = "git" },
    @{ Name = "GitHub CLI";           Id = "GitHub.cli";               CheckCmd = "gh" },
    @{ Name = "Python 3.14";          Id = "Python.Python.3.14";       CheckCmd = "python" },
    @{ Name = "uv 套件管理器";         Id = "astral-sh.uv";             CheckCmd = "uv" },
    @{ Name = "Node.js";              Id = "OpenJS.NodeJS";            CheckCmd = "node" },
    @{ Name = "FFmpeg 全功能版";       Id = "Gyan.FFmpeg";              CheckCmd = "ffmpeg" },
    @{ Name = "Obsidian 筆記庫";       Id = "Obsidian.Obsidian";        CheckCmd = "obsidian" },
    @{ Name = "Tesseract-OCR 辨識引擎"; Id = "UB-Mannheim.TesseractOCR"; CheckCmd = "tesseract" },
    @{ Name = "Poppler PDF 轉換工具";  Id = "oschwartz10612.Poppler";   CheckCmd = "pdftoppm" }
)

foreach ($pkg in $wingetPackages) {
    Refresh-EnvPath
    $isFound = Get-Command $pkg.CheckCmd -ErrorAction SilentlyContinue
    if ($isFound) {
        Write-Success "$($pkg.Name) 已安裝，跳過。"
    } else {
        Write-Info "正在安裝 $($pkg.Name) (ID: $($pkg.Id))..."
        winget install --id $pkg.Id -e --source winget --accept-source-agreements --accept-package-agreements --silent
        Refresh-EnvPath
        if (Get-Command $pkg.CheckCmd -ErrorAction SilentlyContinue) {
            Write-Success "$($pkg.Name) 安裝成功！"
        } else {
            Write-Warn "$($pkg.Name) 已完成安裝指令，環境變數將在重啟後生效。"
        }
    }
}

# ------------------------------------------------------------------------------
# 第二階段：安裝 Python 核心 AI 與多媒體套件
# ------------------------------------------------------------------------------
Write-Header "第二階段：安裝 Python AI 與多媒體套件"
Refresh-EnvPath

$reqFile = Join-Path $PSScriptRoot "requirements_20261111.txt"
if (-not (Test-Path $reqFile)) {
    Write-Err "找不到 requirements_20261111.txt！"
} else {
    Write-Info "偵測到 requirements_20261111.txt，正在安裝 Python 套件..."
    if (Get-Command "uv" -ErrorAction SilentlyContinue) {
        Write-Info "使用 uv 高速安裝套件..."
        uv pip install -r $reqFile --system
    } else {
        Write-Info "使用標準 pip 安裝套件..."
        python -m pip install --upgrade pip
        python -m pip install -r $reqFile
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Python 核心套件安裝成功！"
    } else {
        Write-Warn "部分套件安裝可能需要編譯環境，請檢視上方錯誤訊息。"
    }

    # 安裝 Playwright 瀏覽器核心 (Chromium)
    Write-Info "正在安裝 Playwright 瀏覽器引擎..."
    try {
        python -m playwright install chromium
        Write-Success "Playwright Chromium 瀏覽器安裝完成！"
    } catch {
        Write-Warn "Playwright 瀏覽器安裝跳過或需手動執行。"
    }
}

# ------------------------------------------------------------------------------
# 第三階段：安裝 Node.js 全域套件
# ------------------------------------------------------------------------------
Write-Header "第三階段：安裝 Node.js 工具"
Refresh-EnvPath

if (Get-Command "npm" -ErrorAction SilentlyContinue) {
    Write-Info "正在安裝 @opencode/cli 全域工具..."
    npm install -g @opencode/cli
    if ($LASTEXITCODE -eq 0) {
        Write-Success "@opencode/cli 安裝完成！"
    }
} else {
    Write-Warn "未偵測到 npm，跳過 Node.js 全域套件安裝。"
}

# ------------------------------------------------------------------------------
# 第四階段：部署自訂客製化技能 (auto-video-editor)
# ------------------------------------------------------------------------------
Write-Header "第四階段：還原 auto-video-editor 教學影片自動剪輯技能"

$sourceSkillDir = Join-Path $PSScriptRoot "skills_backup_20261111\auto-video-editor"
$targetSkillDir = Join-Path $env:USERPROFILE ".gemini\config\skills\auto-video-editor"

if (Test-Path $sourceSkillDir) {
    Write-Info "正在將技能還原至：$targetSkillDir"
    if (-not (Test-Path $targetSkillDir)) {
        New-Item -ItemType Directory -Path $targetSkillDir -Force | Out-Null
    }
    Copy-Item -Recurse -Force "$sourceSkillDir\*" $targetSkillDir
    Write-Success "auto-video-editor 技能已成功還原！"
} else {
    Write-Warn "未找到技能備份資料夾，跳過還原。"
}

# ------------------------------------------------------------------------------
# 第五階段：全套環境驗證報告
# ------------------------------------------------------------------------------
Write-Header "第五階段：環境安裝完成度驗證報告"
Refresh-EnvPath

$verifyList = @(
    @{ Name = "Git 版本控管";      Cmd = "git --version" },
    @{ Name = "GitHub CLI";       Cmd = "gh --version" },
    @{ Name = "Python 直譯器";     Cmd = "python --version" },
    @{ Name = "uv 套件管理器";     Cmd = "uv --version" },
    @{ Name = "Node.js 引擎";     Cmd = "node --version" },
    @{ Name = "npm 管理器";       Cmd = "npm --version" },
    @{ Name = "FFmpeg 多媒體";    Cmd = "ffmpeg -version" },
    @{ Name = "Tesseract-OCR";    Cmd = "tesseract --version" },
    @{ Name = "Faster-Whisper";   Cmd = "python -c ""import faster_whisper; print('OK')""" },
    @{ Name = "Edge-TTS 語音合成"; Cmd = "edge-tts --version" },
    @{ Name = "yt-dlp 影音提取";  Cmd = "yt-dlp --version" },
    @{ Name = "Playwright 爬蟲";  Cmd = "python -c ""import playwright; print('OK')""" }
)

Write-Host ("{0,-25} | {1,-10} | {2}" -f "工具項目", "狀態", "版本 / 輸出") -ForegroundColor Cyan
Write-Host "------------------------------------------------------------------" -ForegroundColor Gray

foreach ($item in $verifyList) {
    $out = ""
    try {
        $out = Invoke-Expression $item.Cmd 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) {
            $first = ($out -split "`n")[0].Trim()
            if ($first.Length -gt 35) { $first = $first.Substring(0, 32) + "..." }
            Write-Host ("{0,-25} | {1,-10} | {2}" -f $item.Name, "正常 [OK]", $first) -ForegroundColor Green
        } else {
            Write-Host ("{0,-25} | {1,-10} | {2}" -f $item.Name, "待確認", "重啟終端後生效") -ForegroundColor Yellow
        }
    } catch {
        Write-Host ("{0,-25} | {1,-10} | {2}" -f $item.Name, "未安裝", "需手動安裝") -ForegroundColor Red
    }
}

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "  懶人包建置完畢！若有部分工具顯示待確認，重啟終端機即可生效。" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "按任意鍵關閉此視窗..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
