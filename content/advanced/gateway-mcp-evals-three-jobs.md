+++
title = "Gateway, MCP, evals: three jobs people keep mixing up"
date = 2026-08-30
weight = 12
authorship = "human-ai"
+++

Three tools sit so close together in the agent world that people wire up one and quietly assume they've done the work of another. Then the agent still gives bad answers, and it's not obvious why. The fix is boring: these are three separate jobs, and doing one well says nothing about the other two.

Here they are, plainly:

- **The gateway** decides *which model answers.*
- **MCP** decides *what tools that model can reach.*
- **Evals** tell you *whether the answer was any good.*

Same neighborhood. Three different jobs. Let me take them one at a time.

## Which model answers - the gateway

This is the switchboard. You have a few models around - one in Ollama, maybe one in vLLM, perhaps a cloud key you keep for the hard stuff. A gateway like [LiteLLM]({{< relref "one-door-to-all-your-models" >}}) puts one address in front of all of them, so a request can go to whichever model you name.

That's the whole job. Routing. The gateway does not make the model smarter, and it does not hand it any new abilities. It picks the phone that rings. If you send a coding question to a tiny chat model, the gateway did its job perfectly and the answer is still going to be weak. Wrong model, right routing.

So when people say "I set up LiteLLM," what they've actually built is the part that chooses *who* answers. Useful, and only that.

## What tools it can reach - MCP

A model on its own can only talk. It can't read your files, search the web, or check today's date unless something hands it that ability. MCP (Model Context Protocol) is the standard plug for exactly this: a common way to give a model *tools* it can call - a file reader, a search, a calculator, a connection to your notes.

Think of the model as a clever person locked in a room with no phone and no windows. MCP is the set of doors you choose to unlock. One door lets it read a folder. Another lets it run a search. You decide which doors exist.

Here's where the mix-up bites. Adding tools through MCP does nothing about which model is behind the door, and it says nothing about answer quality. A weak model with ten tools is a weak model that can now reach ten things and still reason badly about all of them. Tools widen what the model can *touch*; they don't raise its judgement.

## Was the answer any good - evals

The first two are about wiring. This one is about the truth. An eval is just a way of checking answers against something you trust - a set of questions with known-good answers, or a second model acting as a judge, or your own eyes on a fixed list of hard cases.

Without evals you're flying on vibes. You change the model, or add a tool, or tweak a prompt, and you *feel* like it got better. Evals turn that feeling into a number you can compare. Did the new setup answer 8 out of 10 of your real questions correctly, or 5? Before and after, same questions.

This is the job people skip most, because it's the least fun and the only one with no shiny tool to install. But it's the only one of the three that can actually tell you the other two are helping. Change the gateway's model, run the eval. Add an MCP tool, run the eval. Otherwise you're guessing, confidently.

## Same neighborhood, three jobs

The trap is that all three live in the same corner of the map, get talked about in the same threads, and often get set up in the same afternoon. So the words blur, and "I built an agent stack" ends up meaning "I did one of these and touched the other two."

Keep them apart and a lot of confusion clears:

- Routing problem - a good model exists but the wrong one is answering? That's the **gateway**.
- Ability problem - the model can't reach the file, the web, the data it needs? That's **MCP**.
- Quality problem - you don't actually know if any change helped? That's **evals**.

None of them is optional in a real setup, and none of them stands in for another. The gateway points at the right model, MCP gives it the right tools, and evals are the only part that ever tells you the truth about the result. Get one and you've got a third of the thing - which is fine, as long as you know that's what you've got.
