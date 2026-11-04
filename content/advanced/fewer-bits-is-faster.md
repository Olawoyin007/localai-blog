+++
title = "Fewer bits is faster: what quantization buys, and what it costs"
date = 2026-09-27
description = "Quantization is sold as a way to fit a model in. On a bandwidth-limited box it is also the main speed control, and its quality cost lands somewhere surprising."
weight = 11
authorship = "human-ai"
+++

Quantization is almost always explained as a way to make a model fit. Store each weight in fewer bits, the file gets smaller, it squeezes onto your machine. True, and it is only half of what it does.

On a box where [speed is set by how many bytes get read for every token]({{< relref "bytes-per-token" >}}), storing fewer bits means reading fewer bytes. So the thing sold to you as a memory saving is also, quietly, the main speed control you have.

If you take one thing from this post: **on a bandwidth-limited machine, quantization is a speed setting. And the quality it costs you does not land where you would guess.**

## The speed half

I measured my 27-billion model at 8 bits per weight. The file is 29GB, it reads all 29GB for every token, and it produces 7.8 tokens a second. Halving the bits should roughly halve the bytes read, and roughly double the speed.

```
27B at 8 bits  = 29 GB read per token  -> 7.8 tok/s measured
27B at 4 bits  = 21 GB read per token  -> about 10.8 tok/s expected
```

Note the second row says expected. That is arithmetic, not a measurement, and I am labelling it as such because the next section is about exactly this kind of confident guess going wrong.

## Four bits does not halve the file

Here is the first trap, found while planning rather than after. Naive maths says 8 bits to 4 bits turns a 29GB file into something near 15GB. The real 4-bit builds of that model are **21 to 23GB**.

The gap is because not every layer gets squeezed. Some stay at higher precision on purpose, because dropping them hurts too much. So you get most of the saving, never all of it, and the shortfall is different for every model.

Which means the honest move is to look at the actual file before promising yourself a speedup. You can read the real size straight off Hugging Face without downloading anything:

```bash
curl -s "https://huggingface.co/api/models/<repo>/tree/main" \
  | python3 -c "import sys,json;print(sum(f.get('size',0) for f in json.load(sys.stdin) if f['path'].endswith('.safetensors'))/1e9)"
```

Thirty seconds, and it replaces a guess with a number.

## The smaller file wins, even when the format is worse

The second trap caught me because I was being clever.

My box is Blackwell hardware, and NVFP4 is the 4-bit format built for it, with native support in the chip. Obviously the one to pick. Except for that 27B the NVFP4 build is 23.4GB and the plain AWQ build is 21GB.

On a machine limited by how fast it reads memory, 21GB beats 23.4GB. The format with the better compute story loses to the format with the smaller file, because compute was never the thing standing in the way.

**Match the choice to your actual bottleneck.** If memory bandwidth is what limits you, the smallest file wins and nothing else about the format matters much.

## The quality half, which surprised me

So quantization is free speed. Obviously it is not, and I wanted to know what it took.

The official numbers for that model, full precision against 4-bit:

| Benchmark | 16 bits | 4 bits | Change |
|---|---|---|---|
| GPQA-Diamond, graduate reasoning | 88.38% | 88.69% | slightly up |
| AIME 2026, competition maths | 98.67% | 84.00% | down 15 points |

Read that twice. Hard graduate-level reasoning is untouched, and if anything a shade better, which is noise. Competition maths falls off a cliff.

Both are difficult. Only one breaks.

{{< fig src="/image/posts/quantization-quality.svg" class="diagram" alt="16-bit against 4-bit on two benchmarks: GPQA-Diamond 88.38 to 88.69, unchanged. AIME 2026 98.67 down to 84.00." caption="Same model, same drop in precision. One benchmark does not notice." >}}

## Why it lands so unevenly

Quantization adds a small rounding error to every weight in the model. What matters is whether a task can absorb a nudge.

Most tasks can, because the right answer sits in a wide basin. Ask for the capital of France and "Paris" stays "Paris" under a small perturbation. There is nothing nearby for the answer to slide into.

A long chain of exact arithmetic is the opposite shape. Step four depends on step three being exactly right. One early rounding error does not get absorbed, it gets carried, and every later step builds on it. There is no basin to fall back into, so a small nudge at the start becomes a wrong answer at the end.

So the thing that predicts whether quantization hurts is not how hard the task is. It is **how many steps depend on the step before.**

> What breaks under quantization is depth of dependency, not difficulty.

In practice that means chat, coding, reading, summarising and retrieval are all fine at 4 bits. You will not notice. Multi-step exact arithmetic is where you will, and if that is your work, pay for the bits.

---

None of this needs my hardware. Wherever memory is the thing holding you back, the same reasoning applies:

- **Treat quantization as a speed control, not only a way to fit.** Fewer bits read is fewer bytes read.
- **Check the real file size before you promise yourself a number.** Four bits does not halve anything, and the shortfall varies.
- **Pick the smaller file over the cleverer format** when bandwidth is your limit.
- **Judge the quality cost by the shape of your work.** Long dependent chains are the thing at risk, not difficulty.

I went looking for how much quality 4 bits would cost me, expecting a flat tax across everything. It is not a tax. It is a narrow hole, in one specific shape of problem, and most of what I actually do walks straight past it.
