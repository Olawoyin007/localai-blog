+++
title = "Setting up a DGX Spark for local LLMs: what it's good at, and where it bit me"
date = 2026-08-10
weight = 17
authorship = "human-ai"
+++

I run my whole local setup on a DGX Spark now - a small NVIDIA box that sits on a desk and holds models a normal graphics card could never fit. This is the honest account of setting it up: what it is genuinely good at, and the one edge that reached out and bit me.

If you take one thing from this post: the whole box lives on a single idea, unified memory, and that idea is both why it is special and how it will reboot itself if you get greedy.

## What it actually is

It is an NVIDIA GB10 machine (the "Spark" class). Three things about it are not like a normal desktop:

- **Unified memory.** 128GB shared between the processor and the GPU, instead of a separate graphics card with its own small pool of memory (VRAM). On a normal desktop GPU you might have 24GB, and a model has to fit inside that. Here a model can reach across most of 128GB. That is why a 100-billion-parameter model runs on a thing the size of a small book.
- **arm64, not x86.** A different processor family from most desktops and servers. Remember this. It comes back later.
- **DGX OS**, which is Ubuntu underneath. Small, quiet, and it runs fully offline. No cloud, no account, no bill.

## Setting it up, the honest short version

You are not wiring this from scratch. NVIDIA ships "playbooks" (a public GitHub repo of self-contained guides), and most capabilities run as containers you start with one flag. The core I stood up:

- **ollama** for the easy, always-on models.
- **vLLM** for the heavier quantized models, using the arm64 build of its container image.
- **one endpoint in front** of both, so everything I run looks like a single API instead of three different ports.

That is the whole serving platform. Image generation, fine-tuning, faster engines - all of it is install-on-demand from the same playbooks, added the day you actually need it. The value you add is not the wiring. It is deciding what to run, and how much memory to hand it. Which is where the trouble started.

## The edge that bit hardest

Unified memory is the gift and the trap, and they are the same feature.

Because the processor and the GPU share one pool, a greedy setting does not just fill "the GPU." It eats the memory the operating system itself needs to stay alive.

I told vLLM it could take 85% of memory, and loaded a 122-billion model. It asked for more physical memory than the machine has. The box ran out, panicked, and hard-rebooted itself. Then it got worse: I had set the container to restart on boot, so the machine came back up and immediately loaded the same too-big model again. A reboot loop, built out of one number I chose.

The fix was dull and correct. Give each model a right-sized memory budget instead of a flat percentage, and do not auto-load a model on boot. Now the box starts clean with nothing loaded, and I load a model by hand when I want one.

**The lesson:** on unified memory, "how much memory does this model get" is a safety setting, not a performance dial. Set it too high and you do not go faster. You take the whole machine down.

## The other honest limits

- **128GB is the ceiling for everything, not spare VRAM.** A model whose raw weights are 136GB simply never fits, unquantized. You live on quantized models (smaller, compressed versions). That is fine, but "128GB" is not "128GB of free room for anything you like."
- **arm64 bites.** Some software has no build for this processor family. You will hit "there is no image for your architecture" walls that an ordinary x86 machine would never see. Budget time for it.
- **The chip is new.** It is recent NVIDIA hardware, and some model files trip loader bugs you end up reporting upstream and waiting on. Bleeding edge cuts both ways.
- **One heavy model at a time.** With vLLM, switching which model is loaded costs real time - a couple of minutes for a small one, closer to ten for the giant.
- **Models are huge.** You need external drives. The internal disk fills faster than you expect.

## What this means for you

If you want a quiet, offline box to experiment with genuinely large models - run several tools side by side, even try training your own - this is rare and good at its size. Almost nothing else this small lets you hold a 100B model in your own room with the network cable unplugged.

If you want a no-thought replacement for the cloud, or you depend on software with no arm64 build, or you were picturing 128GB of spare graphics memory to fill however you like - you will spend your first week fighting it.

It is not a magic cloud in a box. It is a real, capable, slightly sharp-edged experimentation machine. Respect the memory, and it becomes a quietly remarkable thing to have sitting on a desk.
