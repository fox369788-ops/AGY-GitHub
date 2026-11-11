import sys
import subprocess
import time
import json
import os

def render_edit(video_path, clips, output_path, crf=19, preset="faster"):
    """
    clips: list of tuples (start_sec, end_sec) or (start_sec, end_sec, label)
    """
    print(f"=== Rendering {len(clips)} clips to {output_path} ===")
    filter_v = []
    filter_a = []
    concat_inputs = []

    for i, clip in enumerate(clips):
        start = clip[0]
        end = clip[1]
        label = clip[2] if len(clip) > 2 else f"clip_{i+1}"
        dur = end - start
        print(f"[{i+1:2d}] {start:6.2f}s -> {end:6.2f}s ({dur:5.2f}s) | {label}")
        filter_v.append(f"[0:v]trim=start={start}:end={end},setpts=PTS-STARTPTS[v{i}]")
        filter_a.append(f"[0:a]atrim=start={start}:end={end},asetpts=PTS-STARTPTS[a{i}]")
        concat_inputs.append(f"[v{i}][a{i}]")

    n = len(clips)
    concat_filter = "".join(concat_inputs) + f"concat=n={n}:v=1:a=1[outv][outa]"
    full_filter = ";".join(filter_v + filter_a) + ";" + concat_filter

    cmd = [
        "ffmpeg", "-y",
        "-i", video_path,
        "-filter_complex", full_filter,
        "-map", "[outv]",
        "-map", "[outa]",
        "-c:v", "libx264",
        "-preset", preset,
        "-crf", str(crf),
        "-c:a", "aac",
        "-b:a", "192k",
        output_path
    ]

    t0 = time.time()
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print("FFmpeg Render Error:", res.stderr)
        raise RuntimeError("FFmpeg execution failed")
    
    print(f"Render completed successfully in {time.time()-t0:.1f}s!")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python render_edit.py <video_path> <clips_json_path> <output_path>")
        sys.exit(1)
    vid = sys.argv[1]
    with open(sys.argv[2], "r", encoding="utf-8") as f:
        c = json.load(f)
    out = sys.argv[3]
    render_edit(vid, c, out)
