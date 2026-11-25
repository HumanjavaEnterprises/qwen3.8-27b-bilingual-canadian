# Ollama release notes (v2)

Registry name: `vveerrgg/qwen3.8-27b-bilingual-canadian`.

| Tag | Moves? | Points to |
|---|---|---|
| `latest` | moves to the newest version | v2 Q4_K_M |
| `q4_k_m` | moves to the newest version | v2 Q4_K_M |
| `q3_k_m` | moves to the newest version | v2 Q3_K_M |
| `v2` | pinned, never moves | v2 Q4_K_M |
| `v2-q4_k_m` | pinned, never moves | v2 Q4_K_M |
| `v2-q3_k_m` | pinned, never moves | v2 Q3_K_M |
| `q2_k_mix` | v1's file (no v2 equivalent) | v1 Q2_K_mix |
| `v1` | pinned, never moves | v1 Q2_K_mix |
| `v1-q2_k_mix` | pinned, never moves | v1 Q2_K_mix |

The `hf.co/` path reads three small files uploaded next to the GGUF on Hugging Face: `template` (the TEMPLATE block
of the Modelfile), `params` (stops and sampling as JSON) and no `system` file (none is needed).

Before pushing, answer-test both paths on a GPU from a clean container: one English and one French question must get
a direct answer in the same language, with no visible think block and a clean stop.

v2 lesson: Ollama 0.40.x detects Qwen3.8's thinking capability and then renders the chat template EMBEDDED in the GGUF
(`ollama show` reports `template source gguf_chat_template`), ignoring the Modelfile TEMPLATE. The v2 files first
carried Qwen's original template and answered with a visible reasoning block. Fix: the release GGUF embeds the
thinking-off template (same as v1), metadata-only rewrite, tensors byte-identical.
