#!/usr/bin/env bash
set -euo pipefail

PIPER_URL="https://github.com/rhasspy/piper/releases/download/2023.11.14/piper_amd64.tar.gz"
VOICE_URL="https://github.com/rhasspy/piper/releases/download/2023.11.14/voice-el-gr-rapunzelina-low.tar.gz"

echo "=== Installing Flask deps ==="
pip install -r requirements.txt

echo "=== Downloading Piper binary ==="
curl -L --fail --retry 5 --retry-connrefused \
  -H "User-Agent: render-build" \
  -o /tmp/piper.tgz "$PIPER_URL"

# Βεβαιώσου ότι δεν κατέβηκε HTML/σφάλμα
if ! tar -tzf /tmp/piper.tgz >/dev/null 2>&1; then
  echo "Downloaded /tmp/piper.tgz is not a valid tar.gz (maybe HTML/403/404)."
  echo "HEADERS of request:"
  curl -I -L -H "User-Agent: render-build" "$PIPER_URL" || true
  exit 1
fi

tar -xzf /tmp/piper.tgz
chmod +x ./piper

echo "=== Downloading Greek voice (Rapunzelina - low) ==="
mkdir -p voices
curl -L --fail --retry 5 --retry-connrefused \
  -H "User-Agent: render-build" \
  -o /tmp/voice.tgz "$VOICE_URL"

if ! tar -tzf /tmp/voice.tgz >/dev/null 2>&1; then
  echo "Downloaded /tmp/voice.tgz is not a valid tar.gz."
  curl -I -L -H "User-Agent: render-build" "$VOICE_URL" || true
  exit 1
fi

tar -xzf /tmp/voice.tgz -C voices

echo "=== Build done ==="
