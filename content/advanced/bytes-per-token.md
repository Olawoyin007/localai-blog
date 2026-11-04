+++
title = "Bytes per token: why my 122B model is faster than my 27B"
date = 2026-09-23
description = "Why a 122B model can answer faster than a 27B on the same machine, and the one line of arithmetic that predicts it."
weight = 4
authorship = "human-ai"
+++

For a long time I assumed a bigger model would be a slower model. It is the obvious guess, and on my machine it is wrong. My 122-billion model answers faster than my 27-billion one, reliably, on the same box, at the same moment. That is not a misconfiguration. It is arithmetic, and once I understood the arithmetic every speed surprise on this machine stopped being a surprise.

If you take one thing from this post: **parameter count does not set speed. Bytes read per token does.**

## The rule

To write a single word, a model has to read its weights out of memory. How fast it can do that is set by one number on your machine, the memory bandwidth, and one number about the model, how many bytes it has to read for each token.

That gives a ceiling you can work out before you download anything:

```
max tokens/sec  =  memory bandwidth  ÷  bytes read per token
```

My box reads memory at 273 GB/s. That figure is fixed in the hardware and nothing I install will change it. So everything about speed here comes down to the second number.

## Why big can beat small

Here is the part that breaks the intuition. A **dense** model reads every single weight it has, for every token. A **mixture-of-experts** model holds a lot of weights but only reads the few it picks each time.

So the size on disk tells you what has to *fit*. It does not tell you what has to be *read*. Those are different questions, and only the second one sets speed. (What has to fit is its own trap, and mostly [not the weights]({{< relref "what-a-model-costs" >}}).)

Three models, measured on my box, forcing exactly 300 tokens of output each time:

| Model | Shape | Read per token | Measured |
|---|---|---|---|
| `qwen3.8-27b` | dense 27B | 29 GB | 7.8 tok/s |
| `qwen3.5-122b` | MoE 122B, 10B active | about 15 GB | 13-25 tok/s |
| `glm-4.7-flash` | MoE 30B, 3B active | about 2 GB | 42 tok/s |

The smallest model is the fastest and the largest is in the middle, and the ordering follows the third column exactly.

{{< fig src="/image/posts/bytes-per-token.svg" class="diagram" alt="Bytes read per token for three models, with measured speed alongside: 29 GB at 7.8 tok/s, about 15 GB at 13-25, about 2 GB at 42." caption="Bars are bytes read per token. The speed on the right rises as the bar shrinks." >}}

## Checking the rule against the slow one

The dense 27B is the clean test, because dense models read everything and there is nothing to estimate:

```
273 GB/s ÷ 29 GB  =  9.4 tok/s ceiling
measured           =  7.8 tok/s, or 83% of it
```

Eighty-three percent is ordinary real-world efficiency. Which means **that model was already running as fast as this hardware can run it.** There was no setting left to find. I had spent time looking for one.

What convinced me was the repeatability. Three runs back to back:

```
300 tok / 38.3s = 7.8 tok/s
300 tok / 38.2s = 7.8 tok/s
300 tok / 38.3s = 7.8 tok/s
```

When a number repeats to the decimal place like that, you are not looking at a tuning problem. You are looking at a physical limit.

## What this did to the word "flagship"

On a big datacentre card, flagship means the most parameters you can afford. On my box it cannot mean that, because the weights have to fit under roughly 90GB of the 119GB available, leaving room for the scratchpad and the operating system.

So I went looking at what the newest large models actually weigh:

| Model | Size at 4-bit | Fits? |
|---|---|---|
| `GLM-4.7` full | 205 GB | no |
| `Qwen3.8-Flash-Next` | 188 GB | no |
| `Devstral-2-123B` | 150 GB | no |
| `GLM-4.7-REAP-218B` | 130 GB | no |
| `Qwen3.5-122B-A10B` | 77-80 GB | at the ceiling |
| `Qwen3-Next-80B-A3B` | 49 GB | yes |
| `Qwen3.6-35B-A3B` | 25 GB | yes |

Every newest-generation large model lands between 150 and 200GB. They do not load slowly. They do not load at all.

And then the find that changed how I pick: `Qwen3-Next-80B-A3B` runs at **33.3 tok/s** while holding 80 billion parameters of knowledge. My actual flagship, the 122B, manages 13 to 25. The smaller one is faster *and* it holds 74GB instead of 89.

So on a machine like this, flagship does not mean the biggest model that fits. It means **the sparsest model with enough knowledge in it.** Two conditions, and most people only check the first.

## The formula I got wrong

For dense models the rule is exact. Multiply by that 83% and you can predict before downloading:

```
tok/s  ≈  (273 ÷ file size in GB) × 0.83
```

I have checked that twice. A 29GB file predicted 7.8 and measured 7.8. A 20GB file predicted 11.3 and measured 12.2.

For mixture-of-experts models I tried the obvious extension: take the file size and scale it by the fraction of parameters active. On `Qwen3-Next-80B-A3B` that predicted around 150 tok/s.

It measured 33.3. Off by four and a half times.

The reason is worth knowing, because it is the thing the marketing number hides. Only the *expert* layers are sparse. Attention, embeddings, normalisation and some generation-specific layers are read every single token no matter which experts get picked. So the real figure is the shared layers plus the chosen experts, which is a great deal more than the active-parameter count suggests.

Across the three I have measured, the honest range is the file size times somewhere between 0.2 and 0.35. That is wide enough that I would not promise anyone a number from it. For mixture-of-experts models, predict a range and then measure.

## The thing that does not change speed

One last trap, because I fell into it. Modern models have a reasoning setting that controls how much they think before answering. I measured the 27B at every level:

| Setting | tok/s |
|---|---|
| xhigh | 7.8 |
| medium | 7.8 |
| low | 7.8 |
| off | 7.8 |

The reasoning setting changes **how many tokens get written. It never changes how fast they are written.**

It still matters here, but for a different reason. At 7.8 tok/s, every hundred tokens of thinking is thirteen seconds of watching nothing happen. A maximum reasoning default on "rename this variable" is painful on slow hardware in a way it would never be on a fast card.

---

You do not need a 122-billion model, or this box, for any of this to apply. The arithmetic is the same on a laptop, and so are the lessons:

- **Find your machine's memory bandwidth.** It is the ceiling on everything, and it is fixed.
- **Ask what gets read, not what gets stored.** A sparse large model can beat a dense small one.
- **For dense models, predict before you download.** Bandwidth divided by file size, times about 0.83.
- **For sparse models, predict a range and then measure.** The active-parameter number will lie to you.
- **If a result repeats to the decimal, stop tuning.** That is the hardware talking.

There is a second half to this, because storing a model in fewer bits means reading fewer bytes, which makes [quantization a speed setting]({{< relref "fewer-bits-is-faster" >}}) and not only a way to fit.

I spent real hours looking for a setting that would speed up that 27B. There was never one to find. The honest version of fast, on a machine like this, is choosing a model that reads less.
