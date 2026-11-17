#!/usr/bin/env bash
# release/ollama/publish.sh [--push]: build the Ollama library model vveerrgg/qwen3.8-27b-bilingual-canadian.
# The model is the noun, the version an attribute: moving tags latest (= q2_k_mix) and q2_k_mix always point at the
# newest version; pinned tags $VERSION and $VERSION-q2_k_mix (VERSION=v1 default) never move.
# Runs in a throwaway ollama container. Without --push it only creates the tags and shows them. --push publishes them
# (PUBLIC on ollama.com), then pulls latest into a SECOND clean container to prove `ollama run` works.
# GGUF_DIR holds qwen3-8-27b-bilingual-canadian-$VERSION-Q2_K_mix.gguf. KEY is the Ollama device key directory.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
: "${GGUF_DIR:?set GGUF_DIR to the folder holding the release GGUF}"
: "${STORE:?set STORE to a folder for Ollama blobs (big; not next to the key)}"
KEY=${KEY:-$HOME/.local/share/hj-ollama}
NAME=vveerrgg/qwen3.8-27b-bilingual-canadian
VERSION=${VERSION:-v1}
IMG=ollama/ollama:0.40.16
PUSH=${1:-}
C=ollama-publish-$$; trap 'docker stop $C >/dev/null 2>&1 || true' EXIT
docker run -d --rm --name $C -e OLLAMA_MODELS=/models -v "$KEY":/root/.ollama -v "$STORE":/models \
  -v "$GGUF_DIR":/gguf:ro -v "$HERE":/mf:ro $IMG >/dev/null
for i in $(seq 1 60); do docker exec $C ollama list >/dev/null 2>&1 && break; sleep 1; done
sed "s#^FROM .*#FROM /gguf/qwen3-8-27b-bilingual-canadian-$VERSION-Q2_K_mix.gguf#" "$HERE/Modelfile" > "$STORE/Modelfile.$$"
docker exec $C ollama create $NAME:q2_k_mix -f /models/Modelfile.$$ 2>&1 | tail -1
rm -f "$STORE/Modelfile.$$"
docker exec $C ollama cp $NAME:q2_k_mix $NAME:latest
docker exec $C ollama cp $NAME:q2_k_mix $NAME:$VERSION
docker exec $C ollama cp $NAME:q2_k_mix $NAME:$VERSION-q2_k_mix
docker exec $C ollama list | grep bilingual-canadian
docker exec $C ollama show $NAME:latest --modelfile | grep -E "^(FROM|PARAMETER)" | cut -c1-100
if [ "$PUSH" = "--push" ]; then
  for t in latest q2_k_mix $VERSION $VERSION-q2_k_mix; do docker exec $C ollama push $NAME:$t 2>&1 | tail -1; done
  docker stop $C >/dev/null
  C2=ollama-pulltest-$$; trap 'docker stop $C2 >/dev/null 2>&1 || true' EXIT
  docker run -d --rm --name $C2 $IMG >/dev/null
  for i in $(seq 1 60); do docker exec $C2 ollama list >/dev/null 2>&1 && break; sleep 1; done
  docker exec $C2 ollama pull $NAME 2>&1 | tail -1
  docker exec $C2 ollama show $NAME --modelfile | grep -E "^TEMPLATE" | cut -c1-80
  echo "pull test OK"
fi
