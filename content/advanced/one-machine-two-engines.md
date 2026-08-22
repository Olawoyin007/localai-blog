+++
title = "One machine, two engines, one pool of memory"
date = 2026-07-12
weight = 6
authorship = "human-ai"
+++

I run two different programs to run models on the same machine: **Ollama** and **vLLM**. They do not know about each other. But they live in the same memory, and that is where the trouble starts.

This post is the honest story of getting two engines to share one box without knocking it over. If you ever run more than one way of loading models on a single computer, this might save you a bad afternoon.

## Why two engines at all

They are good at different things, so I keep both:

- **Ollama** is the easy one. You ask for a model, it loads it on demand, and it swaps between models for you without fuss. Perfect for casual chat and trying things.
- **vLLM** is the serious one. It is faster under load and gives you precise control, but it runs **one model at a time** and you have to size it by hand.

Nothing clever there. Ollama for easy, vLLM for heavy. The interesting part is what happens when they share a room.

## The one room they share

On my machine, all the memory is one shared pool - about 119GB, used by the system, and by *both* engines at once. This is called unified memory, and it matters here because there is no separate "model memory" to keep them apart. Every model either engine loads comes out of the same single pot.

So the whole game is: **do not let the two of them reach into the pot at the same time and grab more than fits.**

## They grab memory in two very different ways

This is the heart of the drama.

- **Ollama grabs on demand and lets go later.** When you use a model it loads it, holds it for a few minutes in case you come back (a "keep-alive"), then quietly releases it. Polite - but unpredictable. It can show up and grab memory right in the middle of something else.
- **vLLM grabs everything up front and holds it.** The moment it starts a model, it reserves its *entire* memory budget at once - weights plus room to think - and keeps it for as long as it runs. Predictable, but greedy.

One engine that grabs quietly whenever it likes, next to one that grabs a huge amount all at once. You can probably already see the accident coming.

## The day the whole box rebooted

It came for me. vLLM was starting up my flagship, **Qwen3.5-122B** (a very large model, 122 billion), and reserving its big budget. Ollama was still holding a small model from earlier that I had forgotten about - **Llama 3.1 8B** (8 billion). Two hands in the pot, and together they asked for more memory than existed.

On a shared-memory machine, that does not politely fail the model. It runs the kernel - the core of the operating system - out of memory, and the **whole computer hard-reboots**. Not the model crashing. The entire box, gone and restarting.

That is the lesson that turned me careful: over-filling shared memory is not a model error, it is a machine error.

## The hidden memory eater: how many tokens you allow

Here is the part that surprised me most. A small model is not as small as you think.

A model's size on disk is only the weights. Running it, it also needs a scratchpad to hold the conversation so far - and that scratchpad grows with how much text you let it keep in mind (its "context"). Give a small model like **Llama 3.1 8B** (8 billion) a very large context, and its scratchpad alone ballooned to **22GB** on my machine - far more than the weights themselves.

So the number of tokens you allow a model is not just a quality setting. It is a memory decision. Half my memory planning is really context planning: a big model gets a smaller context so its scratchpad fits, a small model can afford a bigger one.

## How I keep the peace

I stopped trusting myself to remember. Now, before either engine loads anything heavy, a small script of mine checks three things: how much memory is *really* free right now, whether the other engine is secretly still holding a model, and whether the new model's budget will actually fit with room to spare. If it would tip over the edge, it refuses to load - on purpose.

It is not clever. It is a seatbelt, written the day after the crash. (I take that script apart in [its own post]({{< relref "the-switcher-i-built" >}}).)

You may never run a 122-billion model. The lessons shrink to any machine:

- **If you run two ways of loading models, they share the same memory.** The second one can crash the first - or, on a shared-memory machine, crash the whole computer.
- **Watch the context length.** A "small" model with a huge context is not small. Tokens cost memory.
- **Leave headroom.** Do not fill memory to the brim. The last little bit is what stops a model error from becoming a machine error.

Two engines on one box is worth it - Ollama's ease and vLLM's speed together. You just have to remember they are sharing a room, and neither of them will remember it for you.
