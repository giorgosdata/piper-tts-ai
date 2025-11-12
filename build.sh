#!/usr/bin/env bash
set -eux

# ===== Install Piper binary (Linux x86_64) =====
# ΣΩΣΤΟ asset: piper_amd64.tar.gz
curl -L -o /tmp/piper.tgz \
  https://github.com/rhasspy/piper/releases/download/2023.11.14/piper_amd64.tar.gz

mkdir -p /tmp/piper_unpack
tar -xzf /tmp/piper.tgz -C /tmp/piper_unpack

# Βρες το εκτελέσιμο 'piper' όπου κι αν βρίσκεται μέσα στο tar και φέρ' το στη ρίζα
if [ -f /tmp/piper_unpack/piper ]; then
  cp /tmp/piper_unpack/piper ./piper
elif [ -f /tmp/piper_unpack/piper_amd64/piper ]; then
  cp /tmp/piper_unpack/piper_amd64/piper ./piper
else
  cp "$(find /tmp/piper_unpack -type f -name piper | head -n1)" ./piper
fi
chmod +x ./piper

# ===== Ελληνική φωνή (Rapunzelina - low) =====
curl -L -o /tmp/el-gr.tgz \
  https://github.com/rhasspy/piper/releases/download/2023.11.14/voice-el-gr-rapunzelina-low.tar.gz

mkdir -p voices
tar -xzf /tmp/el-gr.tgz -C voices
