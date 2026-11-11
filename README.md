# AGY-GitHub

GitHub 帳號認證與遠端倉庫（Repo）建立自動化懶人包。

建立日期：`2026-11-11`

---

## 📦 懶人包檔案清單

- **[setup_github_repo_20261111.bat](file:///C:/AGY-GitHub/setup_github_repo_20261111.bat)**：Windows 批次啟動檔（在任何新電腦下載後，**直接雙擊即可執行**）。
- **[setup_github_repo_20261111.ps1](file:///C:/AGY-GitHub/setup_github_repo_20261111.ps1)**：PowerShell 核心腳本，自動處理工具安裝、GitHub 登入、初始化、建 Repo 與 Push。
- **[README.md](file:///C:/AGY-GitHub/README.md)**：完整說明與手動指令對照手冊。

---

## 🚀 在新電腦上使用方法

1. **下載本專案**：
   - 方式 A：在 GitHub 頁面點擊 **Code -> Download ZIP**，解壓縮到任意資料夾。
   - 方式 B：使用 Git Clone：
     ```bash
     git clone https://github.com/fox369788-ops/AGY-GitHub.git
     ```
2. **執行懶人包**：
   - 點擊執行 `setup_github_repo_20261111.bat`（或在 PowerShell 中執行 `./setup_github_repo_20261111.ps1`）。
3. **依提示操作**：
   - 若電腦未安裝 Git 或 GitHub CLI (`gh`)，腳本會透過 Windows `winget` 自動安裝。
   - 瀏覽器會開啟 GitHub 認證頁面，輸入終端機出現的 8 碼驗證碼並點擊授權。
   - 腳本將自動引導您在本地資料夾初始化 Git 並在 GitHub 建立同名 Repo！

---

## 📖 手動執行工作流程指令對照

如果不想使用腳本，手動操作的 4 大步驟如下：

### 1. 確認與安裝工具
```powershell
# 檢查版本
git --version
gh --version

# 若未安裝，可使用 Windows 內建 winget 安裝
winget install --id Git.Git -e
winget install --id GitHub.cli -e
```

### 2. 使用 GitHub CLI 認證登入
```powershell
# 網頁瀏覽器認證流程
gh auth login --web -h github.com -p https

# 設定 Git 提交身分
git config --global user.name "fox369788-ops"
git config --global user.email "fox369788@gmail.com"
```

### 3. 初始化本地專案 Git
```powershell
cd C:\你的專案資料夾
git init -b main
```

### 4. 建立與資料夾同名的 GitHub Repo 並上傳
```powershell
# 建立 Public Repo 並自動綁定本地 origin
gh repo create <倉庫名稱> --public --source=. --remote=origin

# 提交並推送到 GitHub
git add .
git commit -m "Initial commit"
git push -u origin main
```
