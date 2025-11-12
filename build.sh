#!/usr/bin/env bash
set -eux

# piper (linux x86_64)
curl -L -o /tmp/piper.tar.gz https://github.com/rhasspy/piper/releases/download/2023.11.14/piper_linux_x86_64.tar.gz
tar -xzf /tmp/piper.tar.gz -C .
chmod +x ./piper

# ελληνική φωνή (rapunzelina-low)
mkdir -p voices
curl -L -o /tmp/el-gr.tar.gz https://github.com/rhasspy/piper/releases/download/2023.11.14/voice-el-gr-rapunzelina-low.tar.gz
tar -xzf /tmp/el-gr.tar.gz -C voices
