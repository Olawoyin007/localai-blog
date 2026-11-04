+++
title = "Every meter lied: measuring what a model actually costs"
date = 2026-11-04
weight = 7
authorship = "human-ai"
+++

On one day in October my machine ran out of memory three times. Working out why meant finding out how much things actually cost, and that turned out to be the hard part. Every number I could read was wrong. Not broken, not erroring, just quietly wrong, and one of them was wrong by a factor of three.

If you take one thing from this post: **never trust a number a program reports about its own memory. Measure the difference before and after instead.**

## The whole technique

```bash
B=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
# ... load the model, run the thing ...
A=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
awk "BEGIN{printf \"%.2f GB\n\", ($B-$A)/1048576}"
```

That is it. Read free memory, do the thing, read it again, subtract.

It works for a dull reason. `MemAvailable` is the kernel's own estimate of what is free, it does not care who is asking, and the gap between two readings cannot be flattered by the program you are measuring.

## The model tells you the wrong size

`ollama ps` prints a size for every loaded model. I compared it against a measured delta:

| Model and context | `ollama ps` says | Measured |
|---|---|---|
| `qwen2.5:7b-instruct` at 8,192 | 5.1 GB | 5.93 GB |
| `qwen2.5:7b-instruct` at 16,384 | 5.6 GB | 6.10 GB |
| `qwen3.8:27b` | 18.9 GB | 39 GB |

About 20% low on the small model. **More than double on the 27B.** And because the error is not a consistent percentage, you cannot learn a correction factor and apply it. The number is not slightly off, it is not a measurement of what you think it is.

`ollama ps` will tell you reliably which models are loaded. That is all I use it for now.

## The kernel's own report points at the wrong column

When the out-of-memory killer fires, it prints a table of every process on the machine. Here is the header:

```
[  pid  ]   uid  tgid total_vm      rss rss_anon rss_file ...
```

The fourth number after the pid is `total_vm`, which is **virtual** memory, the address space a process has mapped. The fifth is `rss`, what is actually resident. I read the fourth and believed it, and wrote two confident conclusions into my notes:

- that `llama-server` was holding 15.93 GB, when it was holding 6.10
- that the machine's idle baseline was about 25 GB, when it is about 12

The thing that should have stopped me was printed in the same table. It listed one process at **131 GB** and another at **24 GB**, on a machine with 119 GB of memory in it. A process can map far more address space than physically exists, so those numbers are perfectly normal and perfectly meaningless as a measure of cost.

> If a per-process memory figure is larger than the whole machine, you are reading virtual size. Go and find the header.

And having found the right column, it is still the wrong tool. That table gets printed *during* the kill, after the kernel has already reclaimed what it can. Read it afterwards and almost every process shows near zero. It describes the moment after the damage, not the moment before it.

## The meter that is right for one question and wrong for another

This one is subtler, and it is the reason the box died while I was watching a number that said it was fine.

`MemAvailable` counts anonymous pages as reclaimable, because normally the kernel can push them out to swap. My model server runs with swapping disabled for its own processes. So those pages were counted as available, and they were not available at all.

Here is what the kernel printed at the moment it killed something:

```
Node 0 Normal free:485936kB  min:486180kB
Free swap = 41567756kB
```

Free memory in that zone: 485,936 kB. The minimum the kernel will tolerate: 486,180 kB. **Short by 244 kB.** Meanwhile there were 14 GB of anonymous pages sitting there and 41 GB of free swap, and neither could be touched, because the pages that needed evicting belonged to something forbidden from swapping.

The machine OOM-killed while `MemAvailable` read about 14 GB.

> `MemAvailable` is the right meter for "will this model fit". It is the wrong meter for "is this machine about to fall over". For that, read free pages against the minimum watermark.

## A cold measurement is not a real one

My first reading of a 7B model was taken straight after a three-word prompt: 7.3 GB. Real number, wrong number. A model that has answered one short question has not filled its working memory yet.

Measured again across four full-length questions it settled at 8.2 GB and stayed there.

> Measure under the load the thing will actually carry. Then measure again. Believe it when it stops moving.

## The history you already have

Most Linux boxes are quietly recording this every ten minutes and nobody looks:

```bash
LC_ALL=C sar -r -f /var/log/sysstat/sa03 | awk '/^[0-9]/ {print $1, $3}'
```

That one command gave me the most useful fact of the whole day. With the big model serving, available memory sat at 22.3 to 22.6 GB all morning, flat. I had earlier set a warning threshold at 22 GB, picked by guesswork, which put it **0.3 GB below the machine's completely normal resting state.**

{{< fig src="/image/posts/sar-morning.svg" class="diagram" alt="Available memory across one morning: flat at 22.3 to 22.6 GB, a drop to 6.5 GB at 10:30, recovering to 20.8. A 22 GB threshold line sits just below the flat state." caption="Recorded every ten minutes without being asked. The dip at 10:30 is a measurement being taken, not a problem." >}}

## How all of this fails quietly

Here is what I actually want you to take away, more than any of the commands.

**Every wrong number above produced a confident, plausible table.** None of them threw an error. A 25 GB baseline sounded reasonable. A 16 GB model sounded reasonable. Both went into permanent notes and a commit message before anyone noticed a process was listed as using more memory than the machine contains.

**A measurement taken once looks exactly like a measurement taken carefully.** My cold 7.3 GB and my settled 8.2 GB have the same number of decimal places and the same air of authority.

And the one that unsettles me most: **being conservative for the wrong reason hides the mistake.** That 22 GB threshold came from a misread figure. It happened to be roughly right, for a completely different reason, so it never once failed, so nothing ever revealed that the reasoning behind it was fiction.

---

You do not need a big machine for any of this. The habits are the same anywhere:

- **Measure a delta.** Before, do the thing, after, subtract.
- **Never take a program's word for its own size.**
- **Read the header before you read the column.** If a figure exceeds your total memory, it is virtual.
- **Know which question your meter answers.** "Will it fit" and "is this about to die" are not the same question.
- **Measure under real load, then again, and wait for it to stop moving.**
- **Check `sar`.** Your machine has been keeping notes without being asked.

I lost most of a day to numbers that were never deliberately misleading. They were just answers to questions slightly different from the one I was asking, printed with enough decimal places that I never thought to check.
