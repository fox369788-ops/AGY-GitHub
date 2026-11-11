import sys
import os
import json
import subprocess
import time
from faster_whisper import WhisperModel

def extract_audio(video_path, wav_path):
    print(f"Extracting 16kHz mono WAV from {video_path}...")
    cmd = [
        "ffmpeg", "-y", "-i", video_path,
        "-vn", "-ar", "16000", "-ac", "1", "-c:a", "pcm_s16le",
        wav_path
    ]
    subprocess.run(cmd, check=True, capture_output=True)

def transcribe(video_path, output_json="transcript.json", model_size="small"):
    wav_path = os.path.splitext(video_path)[0] + "_temp16k.wav"
    try:
        extract_audio(video_path, wav_path)
        print(f"Loading faster-whisper model '{model_size}' (CPU, int8)...")
        model = WhisperModel(model_size, device="cpu", compute_type="int8")
        
        print("Transcribing with word-level timestamps...")
        t0 = time.time()
        segments, info = model.transcribe(wav_path, beam_size=5, word_timestamps=True)
        print(f"Detected language: {info.language} (prob: {info.language_probability:.2f})")
        
        results = []
        for seg in segments:
            words = [
                {
                    "word": w.word,
                    "start": round(w.start, 3),
                    "end": round(w.end, 3),
                    "prob": round(w.probability, 3)
                }
                for w in (seg.words or [])
            ]
            results.append({
                "id": seg.id,
                "start": round(seg.start, 3),
                "end": round(seg.end, 3),
                "text": seg.text,
                "words": words
            })
        
        with open(output_json, "w", encoding="utf-8") as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        print(f"Done! {len(results)} segments written to {output_json} in {time.time()-t0:.1f}s")
        return results
    finally:
        if os.path.exists(wav_path):
            os.remove(wav_path)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python transcribe.py <video_path> [output_json]")
        sys.exit(1)
    vid = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else "transcript.json"
    transcribe(vid, out)
