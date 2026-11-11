# AGY-GitHub：全套 AI、影音多媒體與開發環境懶人包

本專案旨在提供新電腦**「開箱即用」**的自動化配置腳本，讓您在全新 Windows 電腦上下載後，只需一鍵執行，即可自動完成工具安裝、環境設定與 GitHub 帳號連接。

建立日期：`2026-11-11`

---

## 📦 專案檔案清單與功能

### 1. 🛠️ 新電腦全套工作環境建置懶人包（排除商業辦公與付費套件）
*已依需求排除 ActivePresenter、CapCut（剪映）與 Office LTSC 2024。*

- **[`install_environment_20261111.bat`](file:///C:/AGY-GitHub/install_environment_20261111.bat)**：雙擊啟動檔，自動繞過 PowerShell 權限限制執行安裝。
- **[`install_environment_20261111.ps1`](file:///C:/AGY-GitHub/install_environment_20261111.ps1)**：安裝核心腳本，涵蓋：
  1. **系統開發工具**：Git, GitHub CLI, Python 3.14, uv, Node.js (`@opencode/cli`)。
  2. **影音多媒體**：Gyan FFmpeg 9.0 (含 `ffprobe`)。
  3. **知識庫與 OCR**：Obsidian, Tesseract-OCR, Poppler (`pdftoppm`)。
  4. **Python AI 套件庫**：Faster-Whisper, PyTorch, Edge-TTS, MoviePy, Playwright, yt-dlp 等。
  5. **專屬技能還原**：自動部署 `auto-video-editor` 教學影片自動剪輯工作流。
- **[`requirements_20261111.txt`](file:///C:/AGY-GitHub/requirements_20261111.txt)**：Python AI 與多媒體相依套件清單。
- **[`skills_backup_20261111/`](file:///C:/AGY-GitHub/skills_backup_20261111/)**：`auto-video-editor` 核心演算法與逐字稿自動對齊腳本備份。

---

### 2. 🐙 GitHub 帳號連接與 Repo 建立懶人包
- **[`setup_github_repo_20261111.bat`](file:///C:/AGY-GitHub/setup_github_repo_20261111.bat)**：一鍵連線啟動檔。
- **[`setup_github_repo_20261111.ps1`](file:///C:/AGY-GitHub/setup_github_repo_20261111.ps1)**：引導完成 GitHub 網頁登入、自動綁定 Git 使用者、初始化本地 Git 並在遠端建立同名 Repo。

---

## 🚀 在新電腦上使用指南

### 情境 A：在新電腦上復刻完整的 AI 與多媒體環境
1. 在新電腦上下載本倉庫（點擊 GitHub 綠色 **Code ➔ Download ZIP** 或以 Git clone）。
2. 解壓縮後，對著 **`install_environment_20261111.bat`** 按右鍵，選擇 **「以系統管理員身分執行」**。
3. 腳本將透過 Windows 官方 `winget` 自動下載並安裝所有工具，並自動安裝 Python 相依套件與還原剪輯技能。
4. 安裝完成後，視窗底部會輸出綠色檢核表，確認各工具皆已就緒。

### 情境 B：在新電腦上連接 GitHub 並建立新專案
1. 雙擊執行 **`setup_github_repo_20261111.bat`**。
2. 依照畫面指引，在跳出的 GitHub 瀏覽器頁面貼上 8 碼驗證碼以授權登入。
3. 指定專案目錄，腳本將自動為您在 GitHub 建立倉庫並推送檔案。

---

## 🎯 此環境所具備的核心能力

1. **教學影片自動剪輯**：Faster-Whisper 語音轉文字、靜音斷崖偵測、口誤自動刪減、FFmpeg 幀級無縫拼接與 SRT 字幕產出。
2. **YouTube 知識萃取與 AI 播客**：`yt-dlp` 下載、字幕提取、筆記整理至 Obsidian、對接 NotebookLM 產出雙人對話式 Podcast。
3. **文件與掃描檔 OCR**：Poppler + Tesseract-OCR 實現掃描 PDF 批次辨識與文字轉換。
4. **現代化網頁爬蟲與自動化**：Playwright 動態網頁自動化擷取。
