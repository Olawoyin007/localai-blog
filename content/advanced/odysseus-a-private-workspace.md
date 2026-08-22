+++
title = "Odysseus: a private AI workspace on my own box"
date = 2026-05-03
weight = 15
authorship = "human-ai"
+++

Everything else on this site has been plumbing - engines, memory, gateways, agents. Useful, but it all lives in a terminal. [Odysseus](https://github.com/odysseus-dev/odysseus) is the friendly face I put on top of it: a self-hosted AI workspace, the local-first version of the ChatGPT or Claude window you already know - running on my own hardware, on my own data.

This is the piece that turns "I run models in a terminal" into "I have a private AI I can actually use, from my phone."

## What it is

Odysseus is a single web app that sits in front of my whole stack. It is open-source, it runs on my box, and everything in it stays on my box. Out of the box it gives me:

- **Chat** with any of my local models - it speaks to vLLM, Ollama, and others, so the same models I serve behind my gateway show up here to talk to.
- **An agent** that can take a task and use tools (web, files, shell, memory) to finish it.
- **Deep research** - multi-step runs that gather sources, read them, and write up a tidy report.
- **Documents, notes, tasks, calendar, and email triage** - the everyday things, with AI as an assistant sitting beside them, not in charge of them.
- **A "cookbook"** that scans my hardware and recommends models that will actually fit - built on [llmfit](https://github.com/AlexsJones/llmfit), the same fit-checker from [the four gates]({{< relref "the-four-gates" >}}).
- **It works on a phone.** It installs like an app and is built for a small screen, not just a desktop.

## How I run it

I run it as a small always-on service on the box, reachable only over my private network - the same tailnet-only approach I use for everything I do not want on the public internet. It connects to the models I already serve, so I am not running anything twice.

I will keep the sensitive details out of this post on purpose - the login, the email account settings, the keys all live in a local environment file that never leaves the machine, and never goes near a git repo. That is the one rule that does not bend: the workspace can be as rich as you like, but its secrets stay home.

## Why it matters

For a long time my local AI was powerful but awkward - great if you were happy in a terminal, invisible to everyone else. Odysseus closes that gap. It is the difference between *owning an engine* and *owning a car you can actually drive*. My models, my email, my notes, my research - all in one private place, usable by a normal human on a normal phone, and all of it staying on my own hardware.

That is the whole sovereign-stack idea finally made comfortable: the AI runs on your own machine, and using it feels as easy as the thing you were trying to replace.

You do not need my hardware to want this. A self-hosted workspace like Odysseus runs on modest machines too, and points at whatever models you have - even a single small one:

- **It gives your local models a proper home** - one calm window instead of a terminal.
- **It keeps your data yours** - email, notes, chats, all local-first.
- **It makes the whole thing shareable** - a private AI the rest of your household can actually use.

The plumbing is what makes local AI *possible*. Something like this is what makes it something you will actually reach for.
