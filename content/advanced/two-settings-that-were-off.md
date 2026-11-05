+++
title = "Two settings that were off, and the speedup that wasn't there"
date = 2026-11-05
weight = 9
description = "Flash attention and a quantised KV cache cut one model's footprint by 42% for no speed cost. The 4x speedup I measured first turned out to be a cold machine."
authorship = "human-ai"
+++

I wrote a while ago about [what a model actually costs]({{< relref "what-a-model-costs" >}}), and the answer was its context, not its weights. That post stops at one lever: cap the context. There are two more, both of them off by default on my machine, and I had never touched either.

So I measured them. The result was better than I expected on memory, and included a four-times speedup that did not exist.

If you take one thing from this post: **flash attention and a smaller cache cost you nothing and save you a lot. And the first number you measure on a cold machine is not a number.**

## The two settings

**Flash attention** changes how attention is computed so it does not have to write the whole intermediate result to memory. Less memory traffic, less memory held.

**KV cache quantisation** stores the conversation cache in fewer bits, the same idea as [quantising the weights]({{< relref "fewer-bits-is-faster" >}}), pointed at the cache instead. In Ollama it is `q8_0` or `q4_0`, and it requires flash attention to be on first.

On my box both were off. The server prints its own configuration at startup and says so plainly:

```
OLLAMA_FLASH_ATTENTION:false   OLLAMA_KV_CACHE_TYPE:f16
```

While I was in there, it also printed the thing my earlier post was about, with the actual number:

```
vram-based default context  total_vram="119.6 GiB"  default_num_ctx=262144
```

A quarter of a million tokens of cache, by default, because the box is large.

## What they save

One model, `llama3.1:8b`, pinned at 32,768 context, measured the only honest way: [free memory before, free memory after]({{< relref "every-meter-lied" >}}).

| flash attention | cache | memory held | tokens/sec |
|---|---|---|---|
| off | f16 | 11.9 GB | 44 |
| on | f16 | 9.6 GB | 44 |
| on | q8_0 | 7.7 GB | 44 |
| on | q4_0 | 6.9 GB | 44 |

**11.9 GB down to 6.9 GB. Forty-two percent, for two environment variables.**

{{< fig src="/image/posts/kv-ladder.svg" class="diagram" alt="Memory held by the same model at four settings: 11.9, 9.6, 7.7 and 6.9 GB, with throughput unchanged at about 44 tokens per second." caption="The bars shrink. The number on the right does not move." >}}

Flash attention on its own takes off 2.3 GB. Moving the cache to 8-bit takes another 1.9. And then the fourth row earns almost nothing: dropping to 4-bit saves 0.8 GB more.

That shape should look familiar if you read the context post. The first cut is worth gigabytes and the second is worth scraps. Take the first one and stop.

## The speedup that wasn't there

Here is the part I nearly published.

My first run of that table did not look like the one above. It looked like this:

| flash attention | cache | tokens/sec |
|---|---|---|
| off | f16 | 10.4 |
| on | f16 | 28.1 |
| on | q8_0 | 45.3 |
| on | q4_0 | 46.1 |

Ten to forty-six. A four-times speedup, in a tidy ascending line, exactly where the story wanted one. I had a headline.

Then I ran it again, because I have written down somewhere that you should. The same settings, second time:

```
off  f16   42.6 tok/s
on   f16   46.0 tok/s
```

The first row had moved by four times. Nothing had changed except that the machine was now warm.

I ran it twice more. Every configuration settles between 41 and 46 tokens a second, and the differences between them are smaller than the noise within them. **Flash attention did not make it faster. The first measurement was taken on a cold box and I read a loading cost as a performance result.**

Note which column survived. The memory figures repeat across all four runs to within 0.15 GB. The speed figures were nonsense until the third pass. One of those columns was measuring a property, the other was measuring my impatience.

## Does the smaller cache make it worse?

It changes the answer. I asked the same question at each precision, temperature zero, same seed, and the responses diverge from the second paragraph onward. So no, this is not invisible.

Whether it is *worse* is a harder question than a couple of prompts can settle. I asked for two things: a time calculation, and the first eight prime numbers.

The primes came back identical and correct at every precision. The arithmetic was wrong at every precision, and wrong differently each time. At full precision it added fifty minutes to 17:05 and decided that made 18:05. At 4-bit it converted three hours fifty minutes into two hundred minutes, which it is not, and got 17:25. The right answer is 17:55 and nothing produced it.

So the fragile thing was already broken before I quantised anything, and the robust thing survived all the way down. That is the same split as [the weights]({{< relref "fewer-bits-is-faster" >}}): what breaks is depth of dependency, not difficulty. Cutting the cache precision changed which wrong road the model took. It did not push it off a road it was on.

That is as far as two prompts can take you. Doing this properly means running a real evaluation at each precision and comparing scores, which is a different piece of work, and one I would rather do than guess at.

---

- **Check whether flash attention is on.** Mine was off and I had never looked.
- **Then quantise the cache to 8-bit.** On this model those two together took off 42%.
- **Do not bother going to 4-bit** unless you need that last gigabyte badly. It saves little and changes more.
- **Measure memory, not speed, unless you are patient.** Memory settles immediately. Throughput lies to you until the machine warms up.
- **Run it twice.** I would have published a four-times speedup that was a cold cache.

The second time I ran that table I was mildly annoyed, because the good headline evaporated. What I got instead was a smaller true number and a reminder that I had written the rule I nearly broke.
