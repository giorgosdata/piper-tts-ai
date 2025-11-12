set -e

pip install -r requirements.txt

python - <<'PY'
from piper.download import download_voice
download_voice('el-gr-rapunzelina-low', out_dir='voices')
print("Voice downloaded to ./voices")
PY
