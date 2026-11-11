---
name: auto-video-editor
description: >-
  Automated video editing for teacher screen recordings, programming tutorials, and screencasts.
  Use this skill whenever the user asks to automatically edit, trim, remove silences/mistakes/repetitions,
  or generate synchronized subtitles for tutorial or instructional screen recording videos.
---

# Auto Video Editor (教學影片自動剪輯專家)

專為教師與講師螢幕教學錄影設計的自動剪輯工作流。結合 **Faster-Whisper 語音辨識（單詞時間戳）**、**多模態影格視覺檢驗** 與 **FFmpeg 單管線幀級合成**，實現無縫剔除口誤、重錄段落、操作翻車與異常長靜音。

---

## 核心流程 SOP

```
[原始教學影片 MP4]
       │
       ├─► 步驟 1: FFprobe 分析影片規格 (1080p, FPS, 聲軌)
       ├─► 步驟 2: Faster-Whisper (CPU, int8, small) 產出逐字稿與單詞時間戳
       ├─► 步驟 3: FFmpeg silencedetect 偵測 >0.8s 的所有靜音斷崖
       ├─► 步驟 4: 多模態影格抽樣 (視覺診斷翻車、誤拖曳、尋找紅框標註 Take)
       ├─► 步驟 5: 規劃 9~N 個 Keep Intervals (保留區間，前後留 0.4~0.8s 呼吸間隔)
       ├─► 步驟 6: FFmpeg filter_complex (trim/atrim/concat) 一次性無縫轉檔
       └─► 步驟 7: 時間軸重算映射，校正資訊科技專有名詞並輸出 .srt 字幕
```

---

## 執行步驟說明

### 步驟 1：前置檢驗
使用 `ffprobe` 檢測輸入影片的長度、解析度與編碼：
```bash
ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height -of json "input.mp4"
```

### 步驟 2：語音轉寫 (ASR)
調用腳本 [transcribe.py](./scripts/transcribe.py) 進行毫秒級單詞時間戳轉寫：
```bash
python scripts/transcribe.py "input.mp4" "transcript.json"
```
* 本地環境採用快取的 `Systran/faster-whisper-small`，在 CPU 上以 `int8` 執行速度極快且準確。

### 步驟 3：靜音與死寂偵測
調用腳本 [detect_silence.py](./scripts/detect_silence.py) 找出所有大於 0.8 秒的靜音區間：
```bash
python scripts/detect_silence.py "input.mp4"
```

### 步驟 4：多模態影格視覺診斷
針對以下可疑點，調用 [sample_frames.py](./scripts/sample_frames.py) 截取關鍵影格：
1. 靜音超過 5 秒至 40 秒的「異常死寂區」。
2. 語音逐字稿中出現重複講述（例如講了多次「在C槽底下」）的重錄區間。
3. 透過 `read_file` 檢視影格，確認：
   - 是否有拖曳失誤、系統警告彈窗？
   - 哪一個 Take 出現了螢幕紅框標註或滑鼠歸位（此為正式 Take）？
   - 是否為軟體載入中的靜止畫面？

### 步驟 5：規劃保留區間（Keep Intervals）
* 刪除所有確定為翻車、口誤、重複嘗試的前次錄製。
* 消除超過 2 秒的無意義畫面凍結（留 0.5~1 秒作為自然操作過渡）。
* 確保每個說話開頭與結尾保留 0.4~0.8 秒氣音緩衝，避免跳切吃字。

### 步驟 6：單管線影音無損合成
調用 [render_edit.py](./scripts/render_edit.py) 執行剪輯：
```bash
python scripts/render_edit.py "input.mp4" "clips.json" "output_edited.mp4"
```
* 採用 `trim`/`atrim` + `concat` 單管線濾鏡，**確保音畫絕對同步，杜絕常見的音訊脫節問題**。

### 步驟 7：字幕時間重算與專有名詞校正
調用 [retime_subtitles.py](./scripts/retime_subtitles.py) 生成新字幕：
```bash
python scripts/retime_subtitles.py "transcript.json" "clips.json" "output_edited.srt" "references/common_typos.json"
```
* 依據 [common_typos.json](./references/common_typos.json) 自動校正常見同音錯字（如「席池疊」→「C槽」、「資料甲」→「資料夾」）。

---

## 參考手冊
* [教師螢幕錄影錄製 SOP 與最佳實踐](./references/recording_sop.md)：向教師提供錄製時的黃金準則（兩秒停頓法則、整句重錄、滑鼠停泊、善用紅框）。
