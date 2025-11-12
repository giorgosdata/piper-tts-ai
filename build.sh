#!/usr/bin/env bash
set -euo pipefail

echo "=== Step 0: Python deps (Flask only) ==="
pip install -r requirements.txt

# 1) Πιθανές εκδόσεις Piper binary (tagged + latest, διάφορα ονόματα)
PIPER_URLS=(
  "https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz"
)


fetch_tar() {
  local out="$1"; shift
  for url in "$@"; do
    echo "---- Trying: $url"
    if curl -L --fail --retry 6 --retry-connrefused \
         -H "User-Agent: render-build" \
         -H "Accept: application/octet-stream" \
         -o "$out" "$url"; then
      if tar -tzf "$out" >/dev/null 2>&1; then
        echo "OK: valid tar.gz from $url"
        return 0
      else
        echo "WARN: $out is not a valid tar.gz (maybe HTML). HEAD:"
        curl -I -L -H "User-Agent: render-build" -H "Accept: application/octet-stream" "$url" || true
      fi
    else
      echo "WARN: download failed for $url"
      curl -I -L -H "User-Agent: render-build" -H "Accept: application/octet-stream" "$url" || true
    fi
  done
  return 1
}

echo "=== Step 1: Download Piper binary ==="
TMPDIR="$(mktemp -d)"
fetch_tar "$TMPDIR/piper.tgz" "${PIPER_URLS[@]}" || {
  echo "FATAL: Could not download Piper binary from any known URL."
  exit 1
}

# Αποσυμπίεση σε προσωρινό folder και εντοπισμός του εκτελέσιμου
mkdir -p "$TMPDIR/unpack"
tar -xzf "$TMPDIR/piper.tgz" -C "$TMPDIR/unpack"

# Βρες το πραγματικό binary όπου κι αν είναι
FOUND_BIN="$(find "$TMPDIR/unpack" -type f -name 'piper' -print -quit || true)"
if [ -z "${FOUND_BIN}" ]; then
  echo "FATAL: No 'piper' binary found after extraction."
  find "$TMPDIR/unpack" -maxdepth 2 -print || true
  exit 1
fi

# Αντέγραψέ το στη ρίζα του project
cp "$FOUND_BIN" ./piper
chmod +x ./piper
file ./piper || true
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

[ -s voices/el-gr-rapunzelina-low.onnx ] || { echo "FATAL: onnx empty"; exit 1; }
[ -s voices/el-gr-rapunzelina-low.onnx.json ] || { echo "FATAL: json empty"; exit 1; }

echo "=== Build done ==="
