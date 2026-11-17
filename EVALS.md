# How Qwen3.8-27B Bilingual Canadian was checked

## Versions

| Version | Date | EN KLD | FR KLD | Belebele FR | Change |
|---|---|---|---|---|---|
| **v1** (current) | 2026-11-17 | 0.0908 | 0.0928 | 0.947 | First public release. |

The evaluation set config for this version is `v1` in
[HumanjavaEnterprises/bilingual-canadian-eval](https://huggingface.co/datasets/HumanjavaEnterprises/bilingual-canadian-eval).

All runs: stock llama.cpp (`llama-perplexity` and `llama-server`), one GPU, thinking off, temperature 0. Three files
compared: the original BF16 weights, this build, and Unsloth's UD-Q2_K_XL (9373.6 MiB; ours 9370.1 MiB).

## Closeness to the original (KL divergence and perplexity)

KL divergence measures how far each file's next-token probabilities are from the original's, on text none of the
files was calibrated or trained on. Lower is closer. "Same top" = how often the most likely next token matches the
original's. 64 chunks of 1,024 tokens per language.

### French: FineWeb-2 fra_Latn, held-out test split

| File | PPL | Mean KLD | 99th pct KLD | Same top |
|---|---|---|---|---|
| Original BF16 | 6.03 | 0 | 0 | 100% |
| **This build** | 6.39 | 0.0928 | 0.85 | 86.5% |
| Unsloth UD-Q2_K_XL | 6.42 | 0.0935 | 0.78 | 86.3% |

Noise on mean KLD is about ±0.0012, so French is level with Unsloth (a hair closer).

### Québec French: FineWeb-2 documents from Québec domains, held out

| File | PPL | Mean KLD | 99th pct KLD | Same top |
|---|---|---|---|---|
| **This build** | 7.12 | 0.0908 | 0.78 | 86.4% |
| Unsloth UD-Q2_K_XL | 7.13 | 0.0913 | 0.73 | 85.3% |

Original BF16 PPL on this text: 6.70. Québec government language-office domains were excluded, so the text does not
overlap the COLE Québec tests.

### English: held-out FineWeb-Edu web text (ODC-By), never used in calibration or training 

| File | PPL | Mean KLD | 99th pct KLD | Same top |
|---|---|---|---|---|
| Original BF16 | 7.69 | 0 | 0 | 100% |
| **This build** | 8.18 | 0.0908 | 0.85 | 87.0% |
| Unsloth UD-Q2_K_XL | 8.16 | 0.0790 | 0.72 | 87.4% |

English drifts further than Unsloth's file. This is the main open gap.

## Task evals

lm-evaluation-harness through stock `llama-server` (OpenAI-compatible chat endpoint), thinking off, temperature 0.

| Task | Original BF16 | This build | Unsloth |
|---|---|---|---|
| Belebele eng_Latn | 0.962 | 0.961 | 0.959 |
| Belebele fra_Latn | 0.949 | 0.947 | 0.936 |
| IFEval EN, prompt-level strict | 0.821 | 0.806 | 0.830 |
| IFEval FR, prompt-level strict | 0.738 | 0.726 | 0.732 |
| GSM8K, 5-shot, flexible match | 0.964 | 0.954 | 0.953 |
| MGSM EN, zero-shot | 0.956 | 0.964 | 0.956 |
| MGSM FR, zero-shot | 0.884 | 0.892 | 0.888 |

MGSM is scored with answer extraction that reads English and French number formats (the stock MGSM regex expects
"The answer is", which none of the three files writes in chat mode). The extraction is in the evaluation set.

GSM8K: 2 of 1,319 answers are empty (the model ends its turn at once).
Earlier builds reached 1 empty answer in 11.

### Canadian civic facts (14 short questions, EN and FR, read by hand)

Official languages of Canada and Québec, the officially bilingual province, Ontario's status, Bill 96 and the Charter
of the French Language. This build answers the official-language questions correctly in both languages (New Brunswick
is the bilingual province; French is Québec's only official language). Its Bill 96 answers are not accurate enough:
see Limitations in the README.

### COLE (French understanding)

**These are COLE dev/validation splits, so they are not comparable to the [COLE leaderboard](https://colebenchmark.org)**,
which reports the test splits. Dataset: [graalul/COLE-public](https://huggingface.co/datasets/graalul/COLE-public). QFrBLiMP and QFrCoLA are evaluation-only by their licences; nothing from COLE was used to build
the model.

| Task | Original BF16 | This build | Unsloth |
|---|---|---|---|
| allocine | .972 | .973 | .975 |
| mms | .747 | .742 | .743 |
| paws_x | .808 | .792 | .792 |
| qfrcola | .800 | .762 | .756 |
| qfrblimp | .895 | .839 | .879 |
| xnli | .762 | .713 | .745 |
| rte3 | .865 | .851 | .825 |
| sickfr | .834 | .867 | .842 |
| gqnli | .519 | .519 | .370 |
| fracas | .805 | .798 | .824 |
| fquad (F1) | .524 | .557 | .618 |
| piaf (F1) | .402 | .426 | .464 |

Extractive question answering (fquad, piaf) and Québec French minimal pairs (qfrblimp) and inference (xnli) are the clearest French weaknesses against Unsloth; on Québec grammaticality (qfrcola) this build is slightly ahead.

## What is in the evaluation set

Per-file KLD/PPL summaries for all three languages, each file's answer and per-item score for every task, and the MGSM
answer-extraction code. Question and reference text is included where the benchmark's licence allows redistribution
(Belebele, GSM8K, IFEval EN/FR, MGSM). COLE text is withheld (non-commercial or unstated licences); those rows carry item
ids so the originals can be matched from the COLE release. Not included: calibration or training data.
