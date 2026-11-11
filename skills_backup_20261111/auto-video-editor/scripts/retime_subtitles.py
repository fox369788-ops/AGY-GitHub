import sys
import json
import os

def orig_to_new_time(t, clips):
    accum = 0.0
    for clip in clips:
        start = clip[0]
        end = clip[1]
        if t < start:
            return None
        if start <= t <= end:
            return accum + (t - start)
        accum += (end - start)
    return None

def format_timestamp_srt(seconds):
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int(round((seconds - int(seconds)) * 1000))
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"

def retime_subtitles(transcript_json, clips, output_srt, typo_dict_path=None):
    with open(transcript_json, "r", encoding="utf-8") as f:
        orig_segs = json.load(f)

    typos = {}
    if typo_dict_path and os.path.exists(typo_dict_path):
        with open(typo_dict_path, "r", encoding="utf-8") as f:
            typos = json.load(f)

    new_subtitles = []
    sub_id = 1

    for seg in orig_segs:
        new_start = orig_to_new_time(seg["start"], clips)
        new_end = orig_to_new_time(seg["end"], clips)

        if new_start is not None and new_end is not None:
            text = seg["text"].strip()
            for k, v in typos.items():
                text = text.replace(k, v)

            if len(text) > 1 and new_end > new_start:
                new_subtitles.append({
                    "id": sub_id,
                    "start": new_start,
                    "end": new_end,
                    "text": text
                })
                sub_id += 1

    srt_lines = []
    for sub in new_subtitles:
        srt_lines.append(str(sub["id"]))
        srt_lines.append(f"{format_timestamp_srt(sub['start'])} --> {format_timestamp_srt(sub['end'])}")
        srt_lines.append(sub["text"])
        srt_lines.append("")

    with open(output_srt, "w", encoding="utf-8") as f:
        f.write("\n".join(srt_lines))

    print(f"Exported {len(new_subtitles)} synchronized subtitles to {output_srt}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python retime_subtitles.py <transcript_json> <clips_json> <output_srt> [typos_json]")
        sys.exit(1)
    t_json = sys.argv[1]
    with open(sys.argv[2], "r", encoding="utf-8") as f:
        c = json.load(f)
    out = sys.argv[3]
    t_dict = sys.argv[4] if len(sys.argv) > 4 else None
    retime_subtitles(t_json, c, out, t_dict)
