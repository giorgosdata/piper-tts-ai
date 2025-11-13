#!/usr/bin/env bash
set -euo pipefail

echo "==> Build script: download Piper binary & Greek voice (el-GR Rapunzelina - low)"

# -----------------------------
# Helpers
# -----------------------------
UA="render-build/1.0"
HDR_ACCEPT="Accept: application/octet-stream"

fetch_tar() {
  # fetch_tar <outfile.tgz> <url1> <url2> ...
  local out="$1"; shift
  for url in "$@"; do
    echo "---- Trying: $url"
    if curl -L --fail --retry 6 --retry-connrefused \
         -H "User-Agent: $UA" -H "$HDR_ACCEPT" \
         -o "$out" "$url"; then
      # Validate tar.gz (and not HTML)
      if tar -tzf "$out" >/dev/null 2>&1; then
        echo "OK: valid tar.gz from $url"
        return 0
      else
        echo "WARN: $out is not a valid tar.gz (maybe HTML). HEAD:"
        curl -I -L -H "User-Agent: $UA" -H "$HDR_ACCEPT" "$url" || true
      fi
    else
      echo "WARN: download failed for $url"
    fi
  done
  return 1
}

fetch_file() {
  # fetch_file <outfile> <url>
  local out="$1"; shift
  local url="$1"
  curl -L --fail --retry 6 --retry-connrefused \
       -H "User-Agent: $UA" -H "$HDR_ACCEPT" \
       -o "$out" "$url"
}

# -----------------------------
# 1) Piper binary candidates
# -----------------------------
PIPER_URLS=(
  "https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz"
  "https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_amd64.tar.gz"
  "https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz"
  "https://github.com/rhasspy/piper/releases/latest/download/piper_amd64.tar.gz"
)

TMPDIR="$(mktemp -d)"

echo "==> Step 1: Download Piper binary"
fetch_tar "$TMPDIR/piper.tgz" "${PIPER_URLS[@]}" || {
  echo "FATAL: Could not download Piper binary from any known URL."
  exit 1
}

# Extract into current project directory (NOT /tmp)
tar -xzf "$TMPDIR/piper.tgz" -C .

# Try to locate the 'piper' executable (in case it was inside a subfolder)
if [[ ! -f "./piper" ]]; then
  FOUND_BIN="$(find . -maxdepth 2 -type f -name 'piper' -print -quit || true)"
  if [[ -n "${FOUND_BIN}" ]]; then
    cp "${FOUND_BIN}" ./piper
  fi
fi

if [[ ! -f "./piper" ]]; then
  echo "FATAL: No 'piper' binary found after extraction."
  exit 1
fi

chmod +x ./piper
file ./piper || true
./piper --help || true

# -----------------------------
# 2) Greek voice (Rapunzelina - low)
# -----------------------------
echo "==> Step 2: Download Greek voice (Rapunzelina - low)"
mkdir -p voices

# Hugging Face exact paths (case-sensitive)
HF_BASE="https://huggingface.co/rhasspy/piper-voices/resolve/main/el/el-GR/rapunzelina-low"
URL_ONNX="$HF_BASE/el-GR-rapunzelina-low.onnx"
URL_JSON="$HF_BASE/el-GR-rapunzelina-low.onnx.json"

# Save with lowercase filenames that το app περιμένει
OUT_ONNX="voices/el-gr-rapunzelina-low.onnx"
OUT_JSON="voices/el-gr-rapunzelina-low.onnx.json"

# Try download low; if fail, fallback to medium
if ! fetch_file "$OUT_ONNX" "$URL_ONNX"; then
  echo "WARN: low onnx failed, trying medium…"
  HF_BASE_MED="https://huggingface.co/rhasspy/piper-voices/resolve/main/el/el-GR/rapunzelina-medium"
  URL_ONNX_MED="$HF_BASE_MED/el-GR-rapunzelina-medium.onnx"
  fetch_file "$OUT_ONNX" "$URL_ONNX_MED"
fi

if ! fetch_file "$OUT_JSON" "$URL_JSON"; then
  echo "WARN: low json failed, trying medium json…"
  HF_BASE_MED="https://huggingface.co/rhasspy/piper-voices/resolve/main/el/el-GR/rapunzelina-medium"
  URL_JSON_MED="$HF_BASE_MED/el-GR-rapunzelina-medium.onnx.json"
  fetch_file "$OUT_JSON" "$URL_JSON_MED"
fi

# Basic size sanity check (>= 1MB)
min_size=1000000
onnx_size=$(stat -c%s "$OUT_ONNX" 2>/dev/null || echo 0)
json_size=$(stat -c%s "$OUT_JSON" 2>/dev/null || echo 0)

if [[ "$onnx_size" -lt "$min_size" || "$json_size" -lt 200 ]]; then
  echo "FATAL: Voice files look incomplete (ONNX=$onnx_size, JSON=$json_size)."
  exit 1
fi

echo "==> Done: Piper + Greek voice installed."
rm -rf "$TMPDIR"
