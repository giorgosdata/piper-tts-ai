from flask import Flask, request, send_file, jsonify
import subprocess, os, time

app = Flask(__name__)

PIPER = "piper"
VOICE_DIR = "./voices"
VOICE = "el-gr-rapunzelina-low"
FFMPEG = "ffmpeg"

def synth(text: str):
    ts = str(int(time.time()))
    out = f"out_{ts}.wav"
    tel = f"out_{ts}_8k.wav"
    subprocess.run(
        [PIPER, "--model", f"{VOICE_DIR}/{VOICE}.onnx",
                 "--config", f"{VOICE_DIR}/{VOICE}.onnx.json",
                 "--output_file", out],
        input=text.encode("utf-8"), check=True
    )
    subprocess.run([FFMPEG, "-y", "-i", out, "-ac", "1", "-ar", "8000", tel], check=True)
    return tel

@app.get("/")
def root():
    return "root ok"

@app.get("/ping")
def ping():
    ok = os.path.exists(VOICE_DIR)
    return ("ok" if ok else "missing files"), 200 if ok else 500

@app.get("/test")
def test_get():
    text = request.args.get("text", "").strip()
    if not text:
        return "Missing ?text=", 400
    tel = synth(text)
    return jsonify({"ok": True, "audio": request.url_root + "audio/" + tel})

@app.post("/tts")
def tts_post():
    data = request.get_json(force=True)
    text = (data or {}).get("text", "").strip()
    if not text:
        return jsonify({"ok": False, "error": "No text"}), 400
    tel = synth(text)
    return jsonify({"ok": True, "audio": request.url_root + "audio/" + tel})

@app.get("/audio/<path:filename>")
def audio(filename):
    if not os.path.exists(filename):
        return "Not found", 404
    return send_file(filename, mimetype="audio/wav")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5055"))
    app.run(host="0.0.0.0", port=port)

