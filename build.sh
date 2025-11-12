#!/usr/bin/env bash
set -e
echo "=== INSTALLING PIPER ==="
curl -L -o piper_amd64.tar.gz https://github.com/rhasspy/piper/releases/download/2023.11.14/piper_amd64.tar.gz
tar -xzf piper_amd64.tar.gz
chmod +x ./piper
echo "=== INSTALLING GREEK VOICE ==="
mkdir -p voices
curl -L -o voice-el-gr-rapunzelina-low.tar.gz https://github.com/rhasspy/piper/releases/download/2023.11.14/voice-el-gr-rapunzelina-low.tar.gz
tar -xzf voice-el-gr-rapunzelina-low.tar.gz -C voices
echo "=== BUILD DONE ==="
