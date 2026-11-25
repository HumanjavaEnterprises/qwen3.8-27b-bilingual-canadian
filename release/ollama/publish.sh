#!/usr/bin/env bash
# release/ollama/publish.sh [--push]: build the Ollama library model vveerrgg/qwen3.8-27b-bilingual-canadian.
# The model is the noun, the version an attribute. For each quant Q in QUANTS (first = default):
#   moving tags  <q> (lowercase) always point at the newest version's file; `latest` = the default quant
#   pinned tags  $VERSION-<q> never move; `$VERSION` = the default quant
# Older versions' pinned tags (v1, v1-q2_k_mix) and their moving tag (q2_k_mix) are left as they are.
# Runs in a throwaway ollama container. Without --push it only creates the tags and shows them. --push publishes them
# (PUBLIC on ollama.com), then pulls latest into a SECOND clean container to prove `ollama run` works.
# GGUF_DIR holds qwen3-8-27b-bilingual-canadian-$VERSION-<Q>.gguf. KEY is the Ollama device key directory.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
: "${GGUF_DIR:?set GGUF_DIR to the folder holding the release GGUF files}"
: "${STORE:?set STORE to a folder for Ollama blobs (big; not next to the key)}"
KEY=${KEY:-$HOME/.local/share/hj-ollama}
NAME=vveerrgg/qwen3.8-27b-bilingual-canadian
VERSION=${VERSION:-v2}
QUANTS=${QUANTS:-"Q4_K_M Q3_K_M"}
IMG=ollama/ollama:0.40.16
PUSH=${1:-}
C=ollama-publish-$$; trap 'docker stop $C >/dev/null 2>&1 || true' EXIT
docker run -d --rm --name $C -e OLLAMA_MODELS=/models -v "$KEY":/root/.ollama -v "$STORE":/models \
  -v "$GGUF_DIR":/gguf:ro -v "$HERE":/mf:ro $IMG >/dev/null
for i in $(seq 1 60); do docker exec $C ollama list >/dev/null 2>&1 && break; sleep 1; done
TAGS=""; first=1
for Q in $QUANTS; do
  q=$(echo "$Q" | tr 'A-Z' 'a-z')
  f=qwen3-8-27b-bilingual-canadian-$VERSION-$Q.gguf
  [ -f "$GGUF_DIR/$f" ] || { echo "missing $GGUF_DIR/$f"; exit 1; }
  sed "s#^FROM .*#FROM /gguf/$f#" "$HERE/Modelfile" > "$STORE/Modelfile.$$"
  docker exec $C ollama create $NAME:$q -f /models/Modelfile.$$ 2>&1 | tail -1
  rm -f "$STORE/Modelfile.$$"
  docker exec $C ollama cp $NAME:$q $NAME:$VERSION-$q
  TAGS="$TAGS $q $VERSION-$q"
  if [ $first = 1 ]; then
    docker exec $C ollama cp $NAME:$q $NAME:latest
    docker exec $C ollama cp $NAME:$q $NAME:$VERSION
    TAGS="latest $VERSION$TAGS"; first=0
  fi
done
docker exec $C ollama list | grep bilingual-canadian
docker exec $C ollama show $NAME:latest --modelfile | grep -E "^(FROM|PARAMETER)" | cut -c1-100
if [ "$PUSH" = "--push" ]; then
  for t in $TAGS; do docker exec $C ollama push $NAME:$t 2>&1 | tail -1; done
  docker stop $C >/dev/null
  C2=ollama-pulltest-$$; trap 'docker stop $C2 >/dev/null 2>&1 || true' EXIT
  docker run -d --rm --name $C2 $IMG >/dev/null
  for i in $(seq 1 60); do docker exec $C2 ollama list >/dev/null 2>&1 && break; sleep 1; done
  docker exec $C2 ollama pull $NAME 2>&1 | tail -1
  docker exec $C2 ollama show $NAME --modelfile | grep -E "^TEMPLATE" | cut -c1-80
  echo "pull test OK"
fi
