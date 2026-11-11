import sys
import os
import subprocess

def sample_frames(video_path, timestamps, output_dir="frames"):
    os.makedirs(output_dir, exist_ok=True)
    extracted = []
    for t in timestamps:
        out_file = os.path.join(output_dir, f"frame_{t:.1f}s.jpg")
        cmd = [
            "ffmpeg", "-y", "-ss", str(t), "-i", video_path,
            "-vframes", "1", "-q:v", "2", out_file
        ]
        subprocess.run(cmd, capture_output=True)
        if os.path.exists(out_file):
            extracted.append(out_file)
    print(f"Extracted {len(extracted)} frames to {output_dir}")
    return extracted

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python sample_frames.py <video_path> <t1,t2,t3...>")
        sys.exit(1)
    vid = sys.argv[1]
    ts = [float(x.strip()) for x in sys.argv[2].split(",") if x.strip()]
    sample_frames(vid, ts)
