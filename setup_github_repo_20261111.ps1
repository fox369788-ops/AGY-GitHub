# ==============================================================================
# GitHub 自動化連接與倉庫建立懶人包 (GitHub Setup QuickPack)
# 建立日期：2026-11-11
# 說明：在全新電腦上一鍵確認工具、登入 GitHub、初始化專案並建立遠端 Repo
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "GitHub 快速設定懶人包 - 2026-11-11"

function Write-Step {
    param([string]$Title)
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Msg)
    Write-Host "[✓] $Msg" -ForegroundColor Green
}

function Write-Info {
    param([string]$Msg)
    Write-Host "[i] $Msg" -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Msg)
    Write-Host "[!] $Msg" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Msg)
    Write-Host "[X] $Msg" -ForegroundColor Red
}

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    GitHub 帳號連接與倉庫建立懶人包 (2026-11-11)    " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 步驟 1：確認與安裝必要工具 (Git & GitHub CLI)
# ------------------------------------------------------------------------------
Write-Step "步驟 1：檢查必要工具 (Git & GitHub CLI)"

# 檢查 Git
$gitInstalled = $false
try {
    $gitVer = git --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $gitVer) {
        Write-Success "Git 已安裝：$gitVer"
        $gitInstalled = $true
    }
} catch {}

if (-not $gitInstalled) {
    Write-Warn "未偵測到 Git！嘗試使用 winget 自動安裝..."
    try {
        winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
        Write-Success "Git 安裝完成，請在新視窗生效後重新執行此腳本。"
    } catch {
        Write-Err "自動安裝失敗，請至 https://git-scm.com/ 手動下載安裝 Git。"
    }
}

# 檢查 GitHub CLI (gh)
$ghInstalled = $false
try {
    $ghVer = gh --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $ghVer) {
        $firstLine = ($ghVer -split "`n")[0]
        Write-Success "GitHub CLI (gh) 已安裝：$firstLine"
        $ghInstalled = $true
    }
} catch {}

if (-not $ghInstalled) {
    Write-Warn "未偵測到 GitHub CLI！嘗試使用 winget 自動安裝..."
    try {
        winget install --id GitHub.cli -e --source winget --accept-source-agreements --accept-package-agreements
        Write-Success "GitHub CLI 安裝完成！"
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        $ghInstalled = $true
    } catch {
        Write-Err "自動安裝失敗，請至 https://cli.github.com/ 手動下載安裝 gh。"
    }
}

if (-not $gitInstalled -or -not $ghInstalled) {
    Write-Err "必要工具尚未安裝完畢，請安裝並重啟終端機後再次執行。"
    Pause
    Exit 1
}

# ------------------------------------------------------------------------------
# 步驟 2：GitHub 帳號認證
# ------------------------------------------------------------------------------
Write-Step "步驟 2：檢查與進行 GitHub 帳號認證"

$authOk = $false
try {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "目前已處於登入狀態："
        $authStatus | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
        $authOk = $true
    }
} catch {}

if (-not $authOk) {
    Write-Info "尚未登入 GitHub，即將開啟網頁認證..."
    Write-Info "請在瀏覽器登入您的 GitHub 帳號並輸入終端顯示的代碼。"
    gh auth login --web -h github.com -p https
    if ($LASTEXITCODE -eq 0) {
        Write-Success "GitHub 登入驗證成功！"
    } else {
        Write-Err "登入失敗或已取消。"
        Pause
        Exit 1
    }
}

# ------------------------------------------------------------------------------
# 步驟 3：設定 Git 使用者資訊
# ------------------------------------------------------------------------------
Write-Step "步驟 3：確認 Git 全域使用者資訊"

$currentName = git config --global user.name
$currentEmail = git config --global user.email

if (-not $currentEmail) {
    $defaultEmail = "fox369788@gmail.com"
    $inputEmail = Read-Host "請輸入 Git 全域 Email (預設: $defaultEmail)"
    if ([string]::IsNullOrWhiteSpace($inputEmail)) { $inputEmail = $defaultEmail }
    git config --global user.email $inputEmail
    Write-Success "已設定 user.email: $inputEmail"
} else {
    Write-Success "目前 user.email: $currentEmail"
}

if (-not $currentName) {
    $defaultName = "fox369788-ops"
    $inputName = Read-Host "請輸入 Git 全域 使用者名稱 (預設: $defaultName)"
    if ([string]::IsNullOrWhiteSpace($inputName)) { $inputName = $defaultName }
    git config --global user.name $inputName
    Write-Success "已設定 user.name: $inputName"
} else {
    Write-Success "目前 user.name: $currentName"
}

# ------------------------------------------------------------------------------
# 步驟 4：指定本地資料夾與初始化 Git
# ------------------------------------------------------------------------------
Write-Step "步驟 4：設定本地專案並初始化 Git"

$currentDir = (Get-Location).Path
Write-Host "當前目錄：$currentDir" -ForegroundColor Cyan
$choice = Read-Host "是否要在當前目錄初始化專案？(Y/n，輸入 n 可指定其他目錄)"
if ($choice -eq 'n' -or $choice -eq 'N') {
    $targetDir = Read-Host "請輸入目標資料夾路徑"
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    Set-Location $targetDir
    $currentDir = (Get-Location).Path
}

$folderName = Split-Path $currentDir -Leaf

# 檢查是否已初始化 Git
if (-not (Test-Path "$currentDir\.git")) {
    git init -b main
    Write-Success "已在 [$currentDir] 初始化 Git 儲存庫（分支：main）"
} else {
    Write-Success "[$currentDir] 已是 Git 儲存庫"
}

# ------------------------------------------------------------------------------
# 步驟 5：在 GitHub 建立遠端 Repo
# ------------------------------------------------------------------------------
Write-Step "步驟 5：建立同名 GitHub 遠端儲存庫"

$repoName = Read-Host "請輸入欲在 GitHub 建立的倉庫名稱 (預設與資料夾同名: $folderName)"
if ([string]::IsNullOrWhiteSpace($repoName)) { $repoName = $folderName }

$visChoice = Read-Host "請選擇倉庫可見度 [1: Public 公開 (預設), 2: Private 私人]"
$visibility = "--public"
if ($visChoice -eq '2') {
    $visibility = "--private"
}

# 檢查 remote origin 是否已存在
$hasOrigin = git remote | Select-String "origin"
if ($hasOrigin) {
    Write-Info "本地已存在遠端 origin："
    git remote -v
} else {
    Write-Info "正在 GitHub 上建立倉庫 [$repoName] 並綁定遠端..."
    gh repo create $repoName $visibility --source=. --remote=origin
    if ($LASTEXITCODE -eq 0) {
        Write-Success "遠端儲存庫 [$repoName] 建立成功！"
    } else {
        Write-Warn "建立過程提示如上。若倉庫已存在，可直接手動綁定 remote。"
    }
}

# ------------------------------------------------------------------------------
# 步驟 6：提交與推送檔案 (可選)
# ------------------------------------------------------------------------------
Write-Step "步驟 6：檢查檔案與推送到 GitHub"

$status = git status --porcelain
if ($status) {
    $pushChoice = Read-Host "偵測到有未提交的檔案，是否立即 commit 並 push 至 GitHub？(Y/n)"
    if ($pushChoice -ne 'n' -and $pushChoice -ne 'N') {
        $commitMsg = Read-Host "請輸入 Commit 訊息 (預設: Initial commit via QuickPack)"
        if ([string]::IsNullOrWhiteSpace($commitMsg)) { $commitMsg = "Initial commit via QuickPack" }
        git add .
        git commit -m $commitMsg
        git push -u origin main
        Write-Success "檔案已成功推送至 GitHub！"
    }
} else {
    Write-Info "目前工作目錄無變更或尚未有檔案。"
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "  恭喜！全部流程已完成！" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "倉庫網址：https://github.com/$(gh api user -q .login 2>$null)/$repoName" -ForegroundColor Yellow
Write-Host "按任意鍵結束..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
