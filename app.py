from flask import Flask, request, send_file, jsonify
import subprocess, os, time

app = Flask(__name__)

@app.route("/tts", methods=["POST"])
def tts():
    data = request.get_json(force=True)
    text = data.get("text", "")
    if not text.strip():
        return jsonify({"ok": False, "error": "No text"}), 400

    ts = str(int(time.time()))
    out = f"out_{ts}.wav"
    tel = f"out_{ts}_8k.wav"

    subprocess.run(["piper", "--model", "el-gr-rapunzelina-low.onnx", "--config",
                    "el-gr-rapunzelina-low.onnx.json", "--output_file", out],
                   input=text.encode(), check=True)
    subprocess.run(["ffmpeg", "-y", "-i", out, "-ac", "1", "-ar", "8000", tel])

    return jsonify({
        "ok": True,
        "audio": request.url_root + "audio/" + tel
    })

@app.route("/audio/<path:filename>")
def audio(filename):
    if not os.path.exists(filename):
        return "File not found", 404
    return send_file(filename, mimetype="audio/wav")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5055)
