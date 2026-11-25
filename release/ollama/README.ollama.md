# Qwen3.8-27B Bilingual Canadian

Qwen3.8-27B for English and French, made to run on one GPU. The 4-bit file scores within about a point of the full-size original on Québec French benchmarks run with the official COLE protocol (QFrCoLA 0.803 vs 0.802, QFrCoRE 0.894 vs 0.895), on maths (GSM8K 0.966 vs 0.964) and on instruction following in both languages (IFEval EN 0.813 vs 0.821, FR 0.754 vs 0.738). Long French answers keep their accents and stay in French. Text in, text out.

*Unofficial build of Qwen3.8-27B by Humanjava Enterprises; not made or endorsed by the Qwen team.*

## Run it

    ollama run vveerrgg/qwen3.8-27b-bilingual-canadian

Ask in English or French; it answers in the language you use. No system prompt needed. Thinking is off.
Needs a recent Ollama (tested on 0.40.16); older releases can't load the Qwen3.8 architecture.

## Tags

| Tag | File | GPU memory (8k context) | Fits |
|---|---|---|---|
| `latest`, `q4_k_m`, `v2`, `v2-q4_k_m` | v2 4-bit (15.7 GiB) | 16.4 GB | 24 GB GPU |
| `q3_k_m`, `v2-q3_k_m` | v2 3-bit (12.6 GiB) | 13.6 GB | 16 GB GPU |
| `v1`, `v1-q2_k_mix`, `q2_k_mix` | v1 2-bit (9.2 GiB) | 10.5 GB | 12 GB GPU |

`latest`, `q4_k_m` and `q3_k_m` move to the newest version; `v2-…` and `v1-…` tags never move.

## Results (v2 4-bit vs the original)

| | Original | v2 4-bit |
|---|---|---|
| COLE QFrCoLA / QFrBLiMP (official protocol) | 0.802 / 0.895 | 0.803 / 0.895 |
| COLE QFrCoRE / QFrCoRT (official protocol) | 0.895 / 0.912 | 0.894 / 0.901 |
| GSM8K | 0.964 | 0.967 |
| MGSM EN / FR | 0.956 / 0.884 | 0.960 / 0.872 |
| IFEval EN / FR (prompt, strict) | 0.821 / 0.738 | 0.813 / 0.754 |

Measured with stock llama.cpp, thinking off, temperature 0. Every answer behind these numbers is in the evaluation set.

## Limits

- Québec civic and legal detail (e.g. Bill 96 specifics) is unreliable: check against official sources.
- Text only; use the original model for images and video.

## Links

- Guide, full results, issues: https://github.com/HumanjavaEnterprises/qwen3.8-27b-bilingual-canadian
- GGUF files: https://huggingface.co/HumanjavaEnterprises/Qwen3.8-27B-Bilingual-Canadian-GGUF
- Evaluation set: https://huggingface.co/datasets/HumanjavaEnterprises/bilingual-canadian-eval
- Original model: https://huggingface.co/Qwen/Qwen3.8-27B

Apache-2.0, same as the base model. Built by Humanjava Enterprises (https://humanjava.com).
