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

VOICE_URLS=(
  "https://github.com/rhasspy/piper/releases/download/2023.11.14/voice-el-gr-rapunzelina-low.tar.gz"
  "https://github.com/rhasspy/piper/releases/latest/download/voice-el-gr-rapunzelina-low.tar.gz"
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

echo "=== Step 2: Download Greek voice (Rapunzelina - low) ==="
mkdir -p voices
fetch_tar /tmp/voice.tgz "${VOICE_URLS[@]}" || {
  echo "FATAL: Could not download Greek voice from any known URL."
  exit 1
}
tar -xzf /tmp/voice.tgz -C voices
ls -l voices || true

echo "=== Build done ==="
