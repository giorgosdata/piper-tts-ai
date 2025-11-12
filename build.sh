#!/usr/bin/env bash
set -euo pipefail

echo "=== Step 0: Python deps (Flask only) ==="
pip install -r requirements.txt

PIPER_URLS=(
  "https://github.com/rhasspy/piper/releases/download/2023.11.14/piper_amd64.tar.gz"
  "https://github.com/rhasspy/piper/releases/download/2023.11.14/piper_linux_x86_64.tar.gz"
  "https://github.com/rhasspy/piper/releases/latest/download/piper_amd64.tar.gz"
  "https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz"
)

fetch_tar() {
  local out="$1"; shift
  for url in "$@"; do
    echo "---- Trying: $url"
    if curl -L --fail --retry 6 --retry-connrefused \
        -H "User-Agent: render-build" \
        -o "$out" "$url"; then
      if tar -tzf "$out" >/dev/null 2>&1; then
        echo "OK: valid tar.gz from $url"
        return 0
      else
        echo "WARN: $out is not a valid tar.gz (maybe HTML). HEAD:"
        curl -I -L -H "User-Agent: render-build" "$url" || true
      fi
    else
      echo "WARN: download failed for $url"
      curl -I -L -H "User-Agent: render-build" "$url" || true
    fi
  done
  return 1
}

echo "=== Step 1: Download Piper binary ==="
fetch_tar /tmp/piper.tgz "${PIPER_URLS[@]}" || {
  echo "FATAL: Could not download Piper binary from any known URL."
  exit 1
}
tar -xzf /tmp/piper.tgz
chmod +x ./piper
./piper --help || true

echo "=== Step 2: Download Greek voice (Hugging Face) ==="
mkdir -p voices
BASE="https://huggingface.co/rhasspy/piper-voices/resolve/main/el/el-GR/rapunzelina/low"
curl -L --fail --retry 6 --retry-connrefused \
  -o voices/el-gr-rapunzelina-low.onnx \
  "$BASE/el-gr-rapunzelina-low.onnx"
curl -L --fail --retry 6 --retry-connrefused \
  -o voices/el-gr-rapunzelina-low.onnx.json \
  "$BASE/el-gr-rapunzelina-low.onnx.json"

# γρήγορος έλεγχος ότι δεν κατέβηκε HTML/άδειο
[ -s voices/el-gr-rapunzelina-low.onnx ] || { echo "FATAL: onnx empty"; exit 1; }
[ -s voices/el-gr-rapunzelina-low.onnx.json ] || { echo "FATAL: json empty"; exit 1; }

echo "=== Build done ==="
