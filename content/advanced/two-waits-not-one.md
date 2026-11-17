+++
title = "Two waits, not one: why a fast model goes slow on a long document"
date = 2026-11-17
weight = 20
description = "The pause after you press enter and the speed of the typing afterwards are two different jobs. A long document makes one of them 250 times longer and the other a third slower."
authorship = "human-ai"
+++

Every local model makes you wait twice. There is the pause after you press enter, when nothing happens. Then there is the typing, when the answer arrives a word at a time.

I always thought of that as one number: the model is fast, or it is slow. When I measured the two halves separately, they turned out to be separate jobs that the machine does in different ways, and they need different fixes.

If you take one thing from this post: **the pause is the model reading, the typing is the model writing, and a long document hits the reading hardest.**

## The two jobs

**Reading** (prefill). Before the model can say anything, it has to take in your whole prompt: your question, the system prompt, and anything you pasted. It does this all at once, every word in parallel. That is heavy arithmetic, so it runs as fast as the chip can do sums. Nothing appears on screen while it happens.

**Writing** (decode). Then the model produces the answer one word at a time. Each new word needs the whole model read out of memory again, which is the point of [bytes per token]({{< relref "bytes-per-token" >}}). So the typing speed is set by how fast memory moves, not by how fast the chip can add.

{{< fig src="/image/posts/two-waits.svg" class="diagram" alt="A timeline of one answer. First a solid bar where the model reads the whole prompt at once and nothing is on screen. Then a row of small blocks where it writes one word at a time." caption="One answer, two jobs. The solid bar is the pause. The small blocks are the typing." >}}

## What I measured

One model, `hermes3:8b`, which is Llama 3.1 8B underneath, on the DGX Spark. Same question every time: explain what a local AI model is. The only change was how much text I pasted in front of it, and the text was this blog's own posts.

Three runs of each, after a warm-up, and then the whole thing again from the start, because [I nearly published a cold machine once]({{< relref "two-settings-that-were-off" >}}). The two passes agreed within 3%.

| pasted in front | prompt tokens | the pause | the typing |
|---|---|---|---|
| just the question | 47 | 0.03 s | 53 tok/s |
| ~1,000 words | 1,378 | 0.38 s | 52 tok/s |
| ~4,000 words | 5,618 | 1.6 s | 46 tok/s |
| ~16,000 words | 21,362 | 7.9 s | 34 tok/s |

{{< fig src="/image/posts/two-waits-measured.svg" class="diagram" alt="Four rows, one per prompt size. The pause grows from 0.03 seconds to 7.9 seconds. The typing speed drops from 53 to 34 tokens per second." caption="The bar is the pause. The number on the right is the typing." >}}

**The pause grew about 250 times. The typing slowed by about a third.**

## Why a long document slows both

The pause is the easy one: more words to read means more time reading. It even grows a little faster than the document, because each word being read gets checked against every word before it, so sixteen times the tokens took twenty-one times as long.

The typing surprised me. I expected it to stay flat, since the model file is the same 4.7 GB whatever you paste. But the model also has to reread its notes on everything it has read so far, the cache from [what a model actually costs]({{< relref "what-a-model-costs" >}}). For this model that is 128 KB per token. With 21,362 tokens in front of it, that is 2.8 GB of extra reading for every word it writes.

So the bytes per word went from 4.7 GB to 7.5 GB, which predicts the typing should fall to 63% of its starting speed. It fell to 64%. That is the same arithmetic as [bytes per token]({{< relref "bytes-per-token" >}}), with the cache added to the pile.

## The second time is free

Ollama keeps what it has already read. Ask about the same document again, and if the start of the prompt has not changed, it skips the reading.

| same 16,000 words | the pause | whole answer |
|---|---|---|
| first time | 7.5 s | 12.9 s |
| second time | 0.03 s | 3.7 s |

That is why it pays to keep the stable part of a prompt at the top, like a long system prompt or a pasted document, and put the part that changes at the bottom. Change the first line and it reads everything again. My test had to do exactly that on purpose, putting a different first line on every run, or the numbers above would have been nonsense.

## Two waits, two fixes

- **If the pause is the problem:** send less, and keep the unchanging part at the start so it can be reused. A faster chip helps too.
- **If the typing is the problem:** read fewer bytes per word. That means a smaller model, [fewer bits]({{< relref "fewer-bits-is-faster" >}}), or faster memory. In a long chat, a [smaller cache]({{< relref "two-settings-that-were-off" >}}) helps as well, since the cache is part of what gets reread.
- **Measure the two separately.** Ollama already does. Run with `--verbose` and it prints a `prompt eval rate` for the reading and an `eval rate` for the writing.

```bash
ollama run hermes3:8b --verbose
```

It also prints a `load duration`, which is a third wait: loading the model from disk the first time you ask. That one only happens once, so it is not in the table.

The pause was the part I expected. The typing slowing down was not, and the reason turned out to be a sum I had already written down in another post.
