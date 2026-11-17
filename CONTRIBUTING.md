# Contributing

Thanks for helping. Merci de votre aide. Reports in English or French are both welcome.

| You found | Where it goes |
|---|---|
| A wrong answer, poor French or English, Canadian usage it gets wrong, or an answer in the wrong language | [Model got something wrong](https://github.com/HumanjavaEnterprises/qwen3.8-27b-bilingual-canadian/issues/new?template=wrong-answer.yml) |
| A broken command, a wrong figure, or a setup that doesn't run | [Guide bug](https://github.com/HumanjavaEnterprises/qwen3.8-27b-bilingual-canadian/issues/new?template=bug.yml) |
| A typo, an unclear step, a missing setup | [Docs fix](https://github.com/HumanjavaEnterprises/qwen3.8-27b-bilingual-canadian/issues/new?template=docs.yml), or open a pull request |
| You hold text or an evaluation set that could make the English or Canadian French stronger (government, public services, education, media, community groups) | [Offer text or an evaluation set](https://github.com/HumanjavaEnterprises/qwen3.8-27b-bilingual-canadian/issues/new?template=data-offer.yml) |
| A security problem | **Privately**, see [SECURITY.md](SECURITY.md) |

## Pull requests

Welcome for the guide and the Ollama files. Keep changes small and focused:

- Run any command you change, as written.
- If you add a memory, speed or score figure, say what you measured on (GPU, runtime and version, context).
- Docs here are Apache-2.0, like the weights; by contributing you agree your contribution is Apache-2.0 too.

The model weights and training are not developed in this repo, so pull requests can't change model behaviour. A
"model got something wrong" report is the way to influence the next version.

## Evaluation sets

We especially welcome evaluation prompts that test what matters in Canada: Québécois and other Canadian French, bilingual
public-service questions, and answers that must stay in the language they were asked in. Open a pull request that adds a
folder under `evals/community/` with the prompts (JSONL), expected answers or a scoring note, and a `SOURCE.md` naming
the author and the licence. We run every merged set against each new version and publish the scores in [EVALS.md](EVALS.md).

## Building it together

This build started with open text and our own measurements. It gets better as more people bring something to the pot:
better Canadian French text, harder tests, real-world reports. Every contribution that lands in a version is credited in
that version's notes.
