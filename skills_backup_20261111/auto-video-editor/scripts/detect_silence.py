import sys
import subprocess
import re
import json

def detect_silence(video_path, noise_db="-30dB", min_duration=0.8):
    cmd = [
        "ffmpeg", "-i", video_path,
        "-af", f"silencedetect=noise={noise_db}:d={min_duration}",
        "-f", "null", "-"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    lines = res.stderr.splitlines()
    
    silences = []
    current_start = None
    
    for line in lines:
        if "silence_start:" in line:
            m = re.search(r"silence_start:\s*([0-9.]+)", line)
            if m:
                current_start = float(m.group(1))
        elif "silence_end:" in line:
            m_end = re.search(r"silence_end:\s*([0-9.]+)", line)
            m_dur = re.search(r"silence_duration:\s*([0-9.]+)", line)
            if m_end and current_start is not None:
                end_time = float(m_end.group(1))
                dur = float(m_dur.group(1)) if m_dur else (end_time - current_start)
                silences.append({
                    "start": round(current_start, 3),
                    "end": round(end_time, 3),
                    "duration": round(dur, 3)
                })
                current_start = None
                
    return silences

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python detect_silence.py <video_path>")
        sys.exit(1)
    sil = detect_silence(sys.argv[1])
    print(f"Detected {len(sil)} silence intervals (>0.8s):")
    for s in sil:
        print(f"  {s['start']:6.2f}s -> {s['end']:6.2f}s (dur: {s['duration']:5.2f}s)")
