# Security Policy

This project publishes a **bilingual (English and French) model build** (weights on Hugging Face and Ollama), the **chat template and
settings** that ship with it, and this guide's docs. People run these on their own
machines, so we treat integrity reports as a priority.

> **Verify your download.** Each Hugging Face repo has a `SHA256SUMS` file: `sha256sum -c SHA256SUMS`.
> Use the latest version (or pin a version tag such as `v1`).

## Reporting a vulnerability

**Please report security issues privately. Do not open a public issue.**

- Use GitHub's **private vulnerability reporting**: Security tab → "Report a vulnerability" (preferred; it reaches
  the maintainers directly), or
- email **security@humanjava.com** with details and steps to reproduce.
- For sensitive reports, you may encrypt to the maintainer's Nostr key (NIP-44 DM); ask for the current npub in your first email.

Please include what you found and its impact, how to reproduce it, and the version you used (Hugging Face revision or
version tag, Ollama tag, and your runtime: Ollama / llama.cpp / LM Studio / vLLM version).

### What to expect
- Acknowledgement within **3 business days**.
- An initial assessment within **7 business days**.
- Coordinated disclosure: we agree a timeline with you before any public detail, and credit you (if you wish) once a
  fix ships.

## Supported versions

| Component | Supported |
|---|---|
| Latest version on Hugging Face and Ollama (`latest`, `v1`, `q2_k_mix`) | ✅ |
| This guide on `main` | ✅ |
| Older revisions | ❌ (please update) |

## In scope
- **Weight integrity:** published files that don't match `SHA256SUMS` or the card.
- **Embedded content:** anything in the GGUF metadata, the chat template, or the Ollama `template` / `system` /
  `params` files beyond what is documented.
- **Commands in this guide:** anything that could run unexpected code or expose data on your machine.

## Not security issues (but please tell us)
- **Wrong answers** (factual errors, poor French or English, answers in the wrong language): open a
  ["Model got something wrong"](https://github.com/HumanjavaEnterprises/qwen3.8-27b-bilingual-canadian/issues/new?template=wrong-answer.yml)
  issue. These are quality reports, and they help us improve the next version.
- Jailbreaks or off-topic outputs: this is a general model build, not a safety system; it keeps the original model's behaviour. Report them as a wrong
  answer if they matter to your use.

## Out of scope
- Vulnerabilities in the runtimes themselves (llama.cpp, Ollama, LM Studio, vLLM): please report those upstream. Tell us
  too if our files are what trigger them.
- Prompt injection or misuse in applications built on this model: guard those at your application's boundary (input
  filtering, invisible-Unicode stripping, tool permissions). The model is not a safety layer.
- Reports generated only by automated scanners, without a demonstrated impact.

## Good-faith safe harbor
We will not pursue or support legal action against researchers who act in good faith, avoid privacy violations and
service disruption, and give us reasonable time to fix things before public disclosure.

## Verify it yourself
- **Checksums.** Every published file is listed in `SHA256SUMS` on the Hugging Face repo, and each version is a git tag
  (`v1`), so a file can't change silently under the same name.
- **Stock runtime, standard format.** The weights are an ordinary GGUF file made only of standard llama.cpp block types.
  It runs in unmodified upstream llama.cpp, with no custom kernels, forks or extra code. A GGUF holds tensors and metadata,
  not executable code.
- **The one piece of logic we ship is the chat template** (Jinja, run by your runtime). It's in plain text in the repo and
  in the GGUF metadata. It should be the upstream Qwen template with thinking turned off and nothing else. If it ever
  differs from what's documented, that's in scope.

## If we have a security incident
This is a small open-source project, not a 24/7 security operation. Here is what we commit to, so you can hold us to it.

**If we confirm a published file was tampered with, or ships something undocumented, we will:**
- Publish an advisory **at or before** the fix ships, not after, on this repo and on the Hugging Face card.
- State plainly which files, versions and dates are affected, and whether re-downloading fixes it.
- Not attribute the problem to user error before the root cause is established.
- Publish a technical write-up within **14 days** of the fix, even if it is unflattering or incomplete (marked as such).

**What we cannot promise.** We do not run a bug bounty and cannot compensate for losses. We cannot reach people who
downloaded a file and never come back, so we announce here, on the Hugging Face card, on humanjava.com and in version
notes, and ask the community to spread the word.

**What we ask of you.** Give us a reasonable window before public disclosure. **If a flaw is being actively exploited,
publish immediately.** User safety beats our coordination.
