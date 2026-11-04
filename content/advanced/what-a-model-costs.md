+++
title = "What a model actually costs: the context, not the weights"
date = 2026-10-04
description = "A 4.4GB model asked for 21GB and took the machine down. The weights were never the problem."
weight = 2
authorship = "human-ai"
+++

A 4.4GB model took my machine down. It asked for 21GB.

The weights were never the problem. I had been choosing models by file size for months, which turns out to be choosing by the smaller of the two numbers that matter.

If you take one thing from this post: **a model's memory cost is mostly its context window. Check that before you check its size.**

## The log line that explained it

When the model loaded, ollama printed its own breakdown. I had seen this line perhaps forty times and read it as noise:

```
memory breakdown [MiB] | total  free  | self = model + context + compute |
                       | 122500 19647 | 21023 = 4403 +  16384  +   236   |
```

Read the right-hand bracket. **4,403 MiB is the weights. 16,384 MiB is the cache for the conversation.** The cache is nearly four times the model.

It needed 21,023 MiB. There were 19,647 free, because something else was holding the rest. So it died. On a machine where [everything shares one pool]({{< relref "one-machine-two-engines" >}}), that is not a model crashing.

{{< fig src="/image/posts/weights-vs-cache.svg" class="diagram" alt="A stacked bar: 4.4 GB of weights, 16 GB of context cache, totalling 21 GB, overshooting a marked line at 19.6 GB free." caption="The small block on the left is the model. The rest is room it reserved for a conversation nobody was going to have." >}}

And the reason it wanted 16GB of cache is that `llama3.1` declares a context length of **131,072 tokens**, and nothing in my setup had told it to use less. The actual job was summarising about 200 lines of log, roughly 10,300 tokens. A twelfth of what it reserved room for.

## Declared context has nothing to do with model size

This is the part that changed how I pick. I asked every model on the box what it declares:

| Model | File size | Declared context |
|---|---|---|
| `llama3.2:1b` | 1.3 GB | 131,072 |
| `granite4.2:3b` | 2.2 GB | 131,072 |
| `gemma3:4b` | 3.3 GB | 131,072 |
| `llama3.1:8b` | 4.4 GB | 131,072 |
| `qwen2.5:3b-instruct` | 1.9 GB | 32,768 |
| `mistral:7b-instruct` | 4.4 GB | 32,768 |
| `qwen2.5:7b-instruct` | 4.7 GB | 32,768 |
| `gemma2:9b` | 5.4 GB | 8,192 |

There is no relationship between the two columns. A 1.3GB model declaring 131,072 is not the cheap option next to a 4.7GB model declaring 32,768. It can easily be the expensive one.

> Pick on declared context, not on the number of parameters in the name.

You can read it without downloading anything, through ollama's `/api/show`.

## What capping actually saves

I measured the same model at three settings, watching free memory before and after:

| Context | Cost |
|---|---|
| 8,192 | 5.93 GB |
| 16,384 | 6.10 GB |
| 32,768 | 7.3 GB |

Two things in there surprised me. Halving from 32,768 to 16,384 saves about 1.3GB, which is real but not dramatic. And halving again, down to 8,192, saves **0.17GB**. Almost nothing.

The cache does not scale the way you brace for. Once the context is sane, the weights dominate again. So there is a large win available in getting from "whatever the model declared" down to something sensible, and very little in squeezing below that. Take the first one and stop.

## Three places to set it, and they are not the same lever

**In the request**, if you control the caller. The ollama API takes `num_ctx` per call. Worth knowing that `ollama run` on the command line has no flag for this, which is why one of my own scripts was rewritten to call the API directly with `curl`.

**In your gateway**, per model, if the app talks to ollama through something else. That is the only lever an application has when it never speaks to ollama directly.

**As a server default**, with `OLLAMA_CONTEXT_LENGTH`. Ollama picks this based on how much memory you have, so on a large box it resolves high, which is exactly why every uncapped caller was getting the maximum.

The server default is the only one that covers callers you do not control, and it is also the one with teeth: anything genuinely sending more than the cap gets **silently truncated**. No error, no warning. The caller gets a confident answer about the part that fitted.

So cap per request where you own the caller, use the server default for the ones you cannot reach, and never set it below the longest prompt anything on the box legitimately sends.

## One copy per context, not per model

A thing I worked out from behaviour rather than from documentation: ollama appears to keep a separate loaded copy for each **combination** of model and context. Two parts of your system asking for the same model at different context settings get two copies of the weights sitting in memory.

Which is why I pinned two of my own services to the same number rather than letting each pick what it would prefer. One of them needs about 10,300 tokens so the smaller setting would truncate it. The other needs 4,000 and would have been fine. They share the larger value, one copy, 6.10GB, instead of two copies of the same weights.

I have not confirmed that from the source. The cost of being wrong is one wasted gigabyte and the cost of matching the numbers anyway was 0.17GB, so I matched them without proving the premise.

## Why it hid for so long

**The default looks like a decision.** Nothing warns you that a model just reserved 131,072 tokens of cache. The line that says so is one of forty, and it reads as information rather than a problem.

**It only bites when something else is holding memory.** That hourly job had been asking for 21GB for weeks, on a box that normally had 110GB free. Completely invisible. It became a crash the day a large model was loaded alongside it. The job did not change. The conditions did.

**Truncation is silent.** Cap too low and nobody gets an error. They get an answer about the part that fitted, which is a far worse failure than a crash, because nothing tells you it happened.

---

The arithmetic is the same on any machine, and smaller machines feel it sooner:

- **Read a model's declared context before you download it.** It is the number that sets the bill.
- **Do not assume the smaller file is the cheaper model.** Often it is not.
- **Get from "whatever it declared" to something sensible, then stop squeezing.** The first cut is worth gigabytes, the second is worth nothing.
- **Match the context across everything using the same model**, or pay for the weights twice.
- **Set a cap below a real prompt and you get silence, not an error.**

I spent months comparing file sizes, because file size is the number everyone puts in the model's name. The number that actually took my machine down was never printed there at all.
