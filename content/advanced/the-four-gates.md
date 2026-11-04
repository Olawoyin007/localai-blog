+++
title = "The four gates: why a model runs on your machine, or doesn't"
date = 2026-08-02
weight = 3
authorship = "human-ai"
+++

Most people run one test on a model: does it fit in memory? If the numbers look okay, they download it and expect it to work.

I used to think that too. Then I actually tried to run a string of big models on my own machine, and watched them fail in four completely different ways. A model does not simply "run" or "not run." It has to pass **four separate gates**, and it can die at any one of them. Only the first is easy to check.

Here they are, in the order you hit them. They apply whether you are on a phone or a server - only the sizes change.

## Gate 1 - Does it fit?

Every model has to fit in your memory to run at all. The rough maths is one honest line: the model's size in billions, times about half a gigabyte per billion (at a normal quality setting), is roughly the memory it needs.

I wanted to run **DeepSeek V4 Flash** (284 billion) after a wave of excited posts about it. One line of that maths said it needed far more memory than *my machine* has. Note the emphasis: there is nothing wrong with the model. It is simply bigger than my memory, and no amount of trying changes that. It never even got downloaded. The only way to "fit" it was to shrink it so hard it got dumber than a smaller model I could already run well.

**The lesson:** this gate is free to check before you download a single byte. You do not even have to do the maths by hand - a small terminal tool called [llmfit](https://www.llmfit.org/) reads your machine and tells you which models will fit and how fast they will run. Check first. It kills most of the hype in one line.

## Gate 2 - Does your software know it?

A model file existing is not the same as your software knowing how to run it. The program that runs models (the "engine") has to understand that model's shape.

I looked at **Inkling** (from Thinking Machines), a brand-new model where a file existed and looked ready. But running it needed a version of the engine that had not been released yet - someone's unfinished work. Again, the model was fine; my software just did not know it yet. Downloading the file would have been pointless; nothing I had could open it.

**The lesson:** the newest, most exciting models often arrive before the software that runs them. Check your engine actually supports it today, not "soon." The same [llmfit](https://www.llmfit.org/) tool helps here too - it only lists models it knows can run, so a model missing from its database is a quiet warning that the software may not be ready.

## Gate 3 - Can it read the weights?

Say the model fits, and your engine knows it. It still has to *read the files*, and that plain step can carry an ordinary bug.

I had a well-sized **Qwen** model that should have been easy - it passed the first two gates comfortably. It stopped on a single missing label deep in the files: a plain software bug in the part that loads them. Nothing wrong with the model, nothing wrong with my machine. The reader just had a bug.

**The lesson:** there is no clever trick for this one. You note it, set it aside, and try again after the software updates. Before you spend hours convinced it is your fault, search a community like [r/ollama](https://www.reddit.com/r/ollama/) - if it is a real bug, someone else has usually hit the same wall and said so. Some walls are just someone else's bug. (And do not let a busy forum make you feel small or behind. Everyone there was new once. You are only there to grab the one answer you came for, then leave.)

## Gate 4 - Do the fast parts run on your chip?

This is the sneaky one. A model can fit, be understood, and load completely - and still die on the very first message.

That happened to me with **Mistral Small 4**. It fit comfortably. It loaded. The engine came up and said it was ready. Then I sent the first message, and it crashed before a single word came back. Deep inside, the fast maths that the model needs would not run on *my particular chip* - my hardware is a slightly different generation than the one those fast parts were written for. This is the clearest "my machine, not the model" of all four: Mistral Small 4 runs fine for plenty of people. It just could not run on mine, yet.

**The lesson:** "fits" and "loads" tell you *nothing* about whether it will actually answer. This gate stays invisible until the first real message. It is the one that surprised me most - and again, [r/ollama](https://www.reddit.com/r/ollama/) is where you find out whether a crash is your setup or your chip generation. (Same as before: go in for your one answer, leave when you have it, and do not measure yourself against anyone posting there.)

The four gates split neatly into two halves:

- **Gates 1 and 2 you can check for free, before downloading.** The size maths, and whether your software supports the model yet - and a tool like [llmfit](https://www.llmfit.org/) answers both at once by reading your machine against its model database.
- **Gates 3 and 4 only show up on your own machine, after the download.** A loader bug, or fast maths that will not run on your chip.

So the honest rule I now live by: **"downloaded and loaded" is only halfway.** A model is not working until a real answer comes back from a real question. Budget the time to find out, and do not trust a model until it has actually spoken to you.

None of this is a reason not to run models yourself. It is the opposite - it is the part you *learn* by doing it yourself, the part a cloud provider quietly handles so you never even know these gates exist. Hitting them is the cost of owning the thing. It is also how you come to actually understand it.
