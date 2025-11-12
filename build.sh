#!/usr/bin/env bash
set -e

# Εγκατάσταση deps από requirements.txt (flask, piper-tts)
pip install -r requirements.txt

# Κατέβασε τη φωνή el-gr-rapunzelina-low στον φάκελο voices/ με τον επίσημο downloader
python - <<'PY'
from piper.download import download_voice
download_voice('el-gr-rapunzelina-low', out_dir='voices')
print("Voice downloaded to ./voices")
PY
