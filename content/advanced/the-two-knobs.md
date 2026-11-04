+++
title = "The two knobs: one is free, one can reboot your box"
date = 2026-10-26
description = "One setting reserves memory up front, the other rations it. Raising the wrong one is free; raising the other can reboot the box."
weight = 15
authorship = "human-ai"
+++

My biggest model was capped at 16,384 tokens per conversation. I had set that months earlier, being careful, and I believed raising it would cost memory I did not have. So I lived with conversations that ran out of room.

That belief was wrong, and the thing that corrected it was already printed in the server's own startup log.

If you take one thing from this post: **the two memory settings on an inference server do completely different jobs, and only one of them costs you anything.**

## What each one actually does

**`--max-model-len`** is how long a single conversation is allowed to get. Question, answer and history together. It is a ceiling on one request.

**`--gpu-memory-utilization`** is the fraction of the machine the server claims up front, the moment it starts. That reservation holds the weights plus a shared pool for all the conversations.

Here is the part I had backwards for months. **Raising the conversation cap does not cost more memory.** The footprint is fixed entirely by the second setting. The cap only decides how much of the *existing* pool a single request is allowed to take.

There is one edge. The server refuses to start if the pool cannot hold even one conversation at the full cap. So the cap is free right up to that point, and then it fails cleanly at startup rather than running out of memory later.

## Read the log instead of guessing

The server tells you the numbers on the way up. You just have to look:

```bash
docker logs vllm 2>&1 | grep -iE 'KV cache|Maximum concurrency'
```

Mine printed:

```
Available KV cache memory: 15.11 GiB
GPU KV cache size: 329,904 tokens
Maximum concurrency for 16,384 tokens per request: 45.14x
```

Read that as: the shared pool is 15 GiB, it holds about 330,000 tokens in total, and at my 16k cap it could serve roughly 45 conversations at once.

I am one person. I was rationing against a limit I was using one forty-fifth of.

## The change, and what it cost

I doubled the cap to 32,768 and left the memory setting exactly where it was. Afterwards:

```
max_model_len: 32768
Available KV cache memory: 15.08 GiB
GPU KV cache size: 325,728 tokens
Maximum concurrency for 32,768 tokens per request: 28.64x
```

The pool is the same 15 GiB. Nothing about the footprint moved. I got twice the conversation length and still have room for 28 at once.

{{< fig src="/image/posts/pool-and-cap.svg" class="diagram" alt="The same 15 GiB pool at two caps: 45 slices at 16,384 tokens, 28 slices at 32,768. The pool width does not change." caption="The pool is fixed. The cap only decides how it gets divided." >}}

One other thing worth checking while you are in there. A comment in my own script said the pool was "about 5GB, tight". That had been true of an older build of the server and was simply stale. The number had moved underneath me and the comment had not.

> Re-measure against the engine that is actually running, not against what you wrote down last time.

## Which knob, and when

Match the knob to what is actually in your way:

**Conversations hitting the length wall, concurrency nowhere near the limit?** Raise the cap. It is free. This was my case and I could have done it months earlier.

**Need more simultaneous users, or the pool genuinely cannot hold one full-length conversation?** Now you have to grow the pool, which means raising the memory fraction, and that one does cost. On a machine where [everything shares one pool of memory]({{< relref "one-machine-two-engines" >}}), over-reserving does not fail politely. Mine hard-rebooted at 0.85.

So nudge that one. Leave headroom. The rule I kept for myself: **if it could run at 90 percent, give it 80.**

The single line to watch is the concurrency figure in the startup log. Keep it comfortably above the number of conversations you actually have at once, and you are fine.

---

None of this is specific to my hardware or my server. Anywhere a program reserves memory up front, the same shape applies:

- **Find out which setting reserves and which setting rations.** They feel similar and behave nothing alike.
- **Read what the thing prints on startup.** It usually tells you its own limits.
- **Check your comments against the running process.** Numbers move when you upgrade.
- **Push the free knob all the way, and nudge the expensive one.**

I spent months writing around a limit that was costing me nothing to keep. The information that would have fixed it had been scrolling past every time the server started.
