+++
title = "Goose: an honest local agent"
date = 2026-05-10
weight = 14
authorship = "human-ai"
+++

I wanted an agent - something I could hand a task to, that would read files, run commands, search the web, and get it done - but running on *my* models, with my work staying on my own machine. [Goose](https://github.com/block/goose), an open-source agent from Block, is what I settled on.

Let me be honest up front, because that is the whole point of this site: it is a reliable backup, not a marvel. It is not as smooth as the polished cloud agents. But it runs entirely on my hardware, on my models, and it gets real work done. For private, local, yours - it is more than good enough.

## How it fits my stack

Goose does not talk to my models directly. It talks to my gateway, and the gateway does the rest:

```
  Goose  --->  LiteLLM (:4000)  --->  my local models (vLLM / Ollama)
```

I point Goose's "OpenAI" provider at the gateway and pick the model I want it to think with - for me, my agentic flagship, a coding-focused model that is good at using tools. That is the entire connection. Because the gateway speaks the standard API, Goose thinks it is talking to OpenAI; it is really talking to my box.

Then I turn on a few of its built-in abilities: reading and writing files and running shell commands, read-only access to my code on GitHub, and web search. Each of those that needs a key keeps its key outside the project, never in anything I would share.

## The one thing that makes or breaks it

An agent is only useful if the model can actually *call tools* - say "run this command" in a way the agent understands. If that translation is not set up, the model will look like it is working ("thinking..."), and then do nothing at all. I wrote about that silent stall in [the two models I run]({{< relref "the-two-models-i-actually-run" >}}); it is the single most common reason a local agent appears broken when the model is fine. Get the tool-calling right first, and Goose comes alive.

## What it is genuinely good at

- **Private by default.** The agent that touches my files and runs my commands is powered by a model on my own machine. My code never leaves the room.
- **Real tasks, not just chat.** It edits files, runs things, checks results, and keeps a little to-do list as it goes.
- **Free to run and always there.** No per-task cost, no account, works offline.

## Where it falls short (the honest part)

- It is **slower** and **less polished** than the big cloud agents. You feel the difference.
- The local model is **less capable** than a frontier cloud one, so it sometimes needs a clearer instruction or a second try.
- It occasionally **fumbles a tool call** and needs a nudge.

None of that is a dealbreaker for me. It is the difference between a car you own outright and a chauffeur you rent. The chauffeur is smoother. But the car is *yours*, it is always in the drive, and everywhere it takes you stays with you.

You do not need my exact models. Goose runs against a small Ollama model on a laptop just as happily:

- **Point it at your gateway (or straight at Ollama)** and pick a model that can call tools.
- **Set the tool-calling up before you judge it** - most "it does nothing" problems are that, not the model.
- **Expect a reliable backup, not a miracle** - and value it for what it is: an agent that is private, free, and entirely yours.
