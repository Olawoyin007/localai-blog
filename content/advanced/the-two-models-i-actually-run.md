+++
title = "The two models I actually run: one to think with, one to work with"
date = 2026-06-07
weight = 11
authorship = "human-ai"
+++

For a long time I chased a single "best" model - the one that would do everything. I stopped when I noticed I was really using two, for two completely different jobs. One I *talk* to. One I *hand tasks* to. They are not ranked against each other. They are different tools.

If you take one thing from this post: you do not need one model to rule them all. You need to know which job you are doing.

## The one I talk to: a thinking model

My chat flagship is **Qwen3.5-122B** - a big mixture-of-experts model (122 billion in total, about 10 billion working per word). This is the one I reach for when I want quality: reasoning, drafting, thinking a problem through out loud with me.

It taught me one gotcha worth passing on. Modern "thinking" models literally show their work - they mutter through their reasoning before giving an answer. That is useful, but by default the muttering can leak straight into the reply, so your clean answer arrives buried in the model thinking to itself. The fix is to tell the server to keep the two apart (a "reasoning parser"), so you get the answer, and the thinking stays behind the curtain where it belongs.

**The lesson for any thinking model:** the reasoning is a feature, but only if it is kept separate from the answer. Check that your setup does that, or every reply will read like someone talking themselves into it.

## The one I hand tasks to: an agentic model

My agentic flagship is **Qwen3-Coder** - a coding-focused model I run as a local, private version of a Claude-Code-style helper. I do not chat with this one. I give it a job and let it use tools: read a file, run a command, edit code, check the result.

This one taught me the most important lesson on the whole box, and it did it by *failing quietly*.

The model was clearly capable. But when I connected my agent to it, it would "think for 26 seconds" and then... nothing. No answer. No action. Just a stall.

Here is what was actually happening. To use a tool, a model speaks a little structured language - "call this tool, with these inputs." The model *was* speaking it. But the server was passing that language through as if it were plain chat text, so the agent on the other end saw neither a real answer nor a real tool call. A capable model, a working agent, and between them a translation that never happened.

The fix was a single setting - a "tool-call parser" that teaches the server to recognise the model's tool language and hand it over properly:

```bash
--enable-auto-tool-choice --tool-call-parser qwen3_coder
```

One flag, and the stall became a working agent.

There was a second, smaller trap right after: an agent reserves a big chunk of space for its own answer, and if you have not left the model enough room to write, it runs out mid-task. So agentic models need two things a chat model does not: the right tool-call translation, and enough output room to actually finish.

**The lesson for any agentic model:** capability is not the whole story. A brilliant model with the wrong plumbing does nothing at all - and worst of all, it fails silently. If your local agent ever "hangs" doing nothing, suspect the tool-call plumbing long before you blame the model.

## Why two, not one

The two flagships map to the two things I actually do:

- **Think with** - conversation, reasoning, writing. You want quality, and the thinking kept tidy.
- **Work with** - tasks, tools, automation. You want reliable tool-calling and room to act.

A model that is wonderful to talk to can be useless as an agent, and the reverse. Ranking them against each other is the wrong question. The right question is which job is in front of you.

## What this means for you

You do not need a 122-billion model, or even two big ones. The split scales all the way down:

- **Keep a model to chat with and a model to do tasks with.** They are different tools; let them be.
- **For the chat one**, make sure its thinking stays out of its answers.
- **For the agent one**, get the tool-calling right before you judge it - and if it stalls silently, that is almost always the plumbing, not the brain.

Chasing the one perfect model kept me stuck. Keeping two honest ones, each good at its own job, is what finally made the box feel like it worked *for* me.
