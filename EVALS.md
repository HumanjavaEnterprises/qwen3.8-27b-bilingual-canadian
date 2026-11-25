# How Qwen3.8-27B Bilingual Canadian was checked

## Versions

| Version | Date | EN / FR / QC KLD (default file) | QFrCoLA test (official) | Change |
|---|---|---|---|---|
| **v2** (current) | 2026-11-25 | 0.0093 / 0.0097 / 0.0093 | 0.803 | 4-bit and 3-bit files calibrated on EN, FR and Québec French; COLE run with the official protocol. |
| v1 | 2026-11-17 | 0.0908 / 0.0928 / 0.0908 | 0.780 | First public release (2-bit-class file). |

The evaluation set configs are `v2` and `v1` in
[HumanjavaEnterprises/bilingual-canadian-eval](https://huggingface.co/datasets/HumanjavaEnterprises/bilingual-canadian-eval).

# v2

All runs: stock llama.cpp (`llama-perplexity` and `llama-server`), one GPU, the model's own chat template, thinking
off, temperature 0. Files compared: the original BF16 weights, the v2 4-bit file (Q4_K_M, 15.69 GiB) and the v2 3-bit
file (Q3_K_M, 12.61 GiB); v1 where it was measured the same way.

## COLE, official protocol (Québec French)

The COLE authors' own prompts and answer parsing ([COLE](https://github.com/GRAAL-Research/COLE)), answers returned
through the tool-call path, one request at a time, temperature 0. Splits: QFrCoLA test (7,546 items), QFrBLiMP dev
(124; its test labels are not public), QFrCoRE test (4,633), QFrCoRT test (171). Accuracy:

| Task | Original BF16 | v2 4-bit | v2 3-bit | v1 |
|---|---|---|---|---|
| QFrCoLA (grammaticality), test | 0.802 | 0.803 | 0.803 | 0.780 |
| QFrBLiMP (minimal pairs), dev | 0.895 | 0.895 | 0.879 | 0.855 |
| QFrCoRE (Québec expressions), test | 0.895 | 0.894 | 0.885 | 0.864 |
| QFrCoRT (Québec terms), test | 0.912 | 0.901 | 0.895 | 0.865 |

Unparseable answers: 0 for the original and both v2 files (v1: 5 on QFrCoLA, 1 on QFrBLiMP). On QFrCoRT the 4-bit
file is 2 items of 171 behind the original. Nothing from COLE was used to build any file; QFrBLiMP and QFrCoLA are
evaluation-only by their licences.

## Closeness to the original (KL divergence)

KL divergence of each file's next-token probabilities from the original's, on held-out text none of the files was
calibrated on (lower is closer). "Same top" = how often the most likely next token matches the original's.

| File | EN KLD | FR KLD | QC KLD | Same top EN / FR / QC |
|---|---|---|---|---|
| v2 4-bit | 0.0093 | 0.0097 | 0.0093 | 95.5% / 95.2% / 95.1% |
| v2 3-bit | 0.0355 | 0.0393 | 0.0383 | 91.3% / 90.9% / 90.5% |
| v2 2-bit (not shipped) | 0.110 | 0.119 | 0.114 | 85.2% / 84.5% / 84.2% |

Noise on these means is about ±0.0002 (4-bit) to ±0.0015 (2-bit). French drifts slightly more than English at every
size, but the gap is small; Québec French is level with English or between the two.

## Task evals

lm-evaluation-harness through stock `llama-server` (chat-completions endpoint, `--apply_chat_template`), thinking off,
temperature 0, seed 0.

| Task | Original BF16 | v2 4-bit | v2 3-bit |
|---|---|---|---|
| GSM8K, 5-shot, flexible match | 0.964 | 0.967 | 0.964 |
| MGSM EN, zero-shot | 0.956 | 0.960 | 0.960 |
| MGSM FR, zero-shot | 0.884 | 0.872 | 0.876 |
| IFEval EN, prompt-level strict | 0.821 | 0.813 | 0.808 |
| IFEval FR, prompt-level strict | 0.738 | 0.754 | 0.736 |

MGSM uses answer extraction that reads English and French number formats (in the evaluation set).

## Long French answers

12 long-answer requests (6 standard French, 6 Québec French) × 4 contexts: none; an 8k- and a 24k-token French
document before the request; an 8k-token English document with the answer asked for in French. Greedy, 900 tokens.

| | Original | v2 4-bit | v2 3-bit | v2 2-bit (not shipped) |
|---|---|---|---|---|
| Accented letters (% of letters) | 3.5 | 3.5 | 3.4 | 3.4 |
| Words missing accents, per 1,000 | 0.22 | 0.21 | 0.24 | 0.16 |
| Sentences flagged English (%) | 0.25 | 0.23 | 0.17 | 0.05 |
| Repeated phrases (%) | 0.33 | 0.35 | 0.35 | 2.34 |

Every sentence the language detector flagged as English was read by hand: all are French (short sentences, or French
naming an English proper noun). The few "missing accent" words are correct French verb forms, the same in every file.
The 2-bit file loops in long answers, which is why it is not shipped.

## Canadian civic facts

Official-language basics are correct in both languages. Québec's Bill 96 in detail is not: 7 of 16 questions right
(see Limitations).

## How we measured (and why your numbers may differ)

Chat template, stop tokens, system prompt, thinking mode and sampling all move scores, sometimes by many points. One
example from our own comparisons: a GGUF whose end-of-turn token is not marked as a stop token prints that token at the
end of every answer, and IFEval's format checks then fail. To reproduce these numbers use the bundled template, thinking
off, temperature 0, and the harness settings above; when comparing models, run them all the same way.

# v1 (2026-11-17)

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
