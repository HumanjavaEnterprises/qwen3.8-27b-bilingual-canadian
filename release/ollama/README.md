# Ollama release notes (v1)

Registry name: `vveerrgg/qwen3.8-27b-bilingual-canadian`.

| Tag | Moves? | Points to |
|---|---|---|
| `latest` | moves to the newest version | v1 Q2_K_mix |
| `q2_k_mix` | moves to the newest version | v1 Q2_K_mix |
| `v1` | pinned, never moves | v1 Q2_K_mix |
| `v1-q2_k_mix` | pinned, never moves | v1 Q2_K_mix |

The `hf.co/` path reads three small files uploaded next to the GGUF on Hugging Face: `template` (the TEMPLATE block
of the Modelfile), `params` (stops and sampling as JSON) and no `system` file (none is needed).

Before pushing, answer-test both paths on a GPU from a clean container: one English and one French question must get
a direct answer in the same language, with no visible think block and a clean stop.
